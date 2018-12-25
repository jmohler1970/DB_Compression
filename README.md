# Introduction

I am going to argue against data normalization and I am going to be using traffic tracking as an example.

I am going to introduce some better approaches to get the job done.

## What to call this

I was thinking of all kinds of title for this video

- Don't normalize that data
- Intro to DB Compression
- Normalization is not the answer
- Stop wasting your time with normalization
- Traffic tracking for the rest of us
- How I learned to stop worring and learn to love data compression
- My cat is not normal, and neither are you



## About the traffic tracking

I want to store traffic information on my database. In particular I want to store

- CreateDate: When a request came in
- Endpoint: What was requested. I have about 10 to 15 endpoints
- Verb: What verb was used
- IP: I am going to use IPs to track the number of visitors. I am not going to worry about firewalls and things like that.
- User_agent: I want to know what kind of a browswer or requestor is being used 


## Goals for this video

1. I want to give an example of where normalizing data makes it impossible to manage
2. I want to explain on SQL Server data compression works
3. I want to argue that using SQL data compression will achieve most of the goals that data normalization tries to achieve
4. I want to show how to create a compressed indexed view
5. I want to talk about how that is useful.



# Working the problem


## Plan A

I have been doing a lot with ORM lately. Let me start with how I see the data being saved. Let's move to the create script. The first easy approach is just save the data along with a Identity to be the primary key. I am concerned how wide these columns are. I don't think this is going to be space efficient. `User_Agent` alone is very large.

Everytime a hit goes to my Taffy site, I think a whole page worth data will be added in. I know that Endpoints, Verbs, IPs, and User agents are going to repeat often, so this leads to Plan B


## Plan B

I do have the create script for this, but it is easier if I just show a diagram of a normalized version of this. We have four tables all with foreign key relationships to the main table. You can see we have a table for

- Endpoint
- Verb
- IP
- User_agent


### Rule of thumb

One of my rules of thumb is to assume that any given system will be around 10 years later. I will be collecting all this data. Do I really want to keep `Endpoint_Enhanced`, `IP_Enhanced`, `Verb_Enhanced`, and `User_Agent_Enhanced` with all of their valid values for 10 years? Won't some of this data be obsolete?

There is no clean way to scrub this data. I expect that a lot IP and User_Agent information will be highly useless in 10 years.


### about the CFCs

Now let's think about the CFCs that would be needed for this... all five of them. Sometimes the will have to inserts on the outlying tables. Sometimes they will have to do selects. Plan A for all of its problems, entailed only one insert operation. Between detecting and conditionally inserting, this is going to have a lot database interactions. I have only included the build scripts in Github. This is just too much to build out. 



## Plan C

Let's go back to plan A and do some cleanup. First off my data is too long. I don't really need IP. I just need to know how many unique IPs there are. So let's just save a `CHECKSUM()` of that. 

`User_Agent` can be very long. I have heard up to 16k. I don't want to save all that. I am just going to cut it off at 255 characters.

Now we are going to do some serious reduction. We are going to build the table with compression.

```
WITH (DATA_COMPRESSION = PAGE);
```

So how this type of compression work? It will do the following:
- It is going to look for redundant data in the same row (I don't expect much of this)
- It is going to look for redundant data in the start of string (`User_Agent` and `endpoint` are going to have a little of this.)
- It is going to look for redundant data across rows. (There is going to be a lot of this)

Anytime it sees `endpoint` or `verb` or `ip_hash` or `user_agent` repeating, it will just save a reference to it. It does not physically save the string. I am expecting a 3 to 1 to a 10 to 1 compression ratio out of this. 

### Now with view

I am going to create a view too, but this is not a normal view.

I collect data as traffic come in, but it is very common to evaluate data on a daily basis. I don't want to even touch `dbo.Traffic`, if I don't have to. Here is what we are going to do with the view

Line 22: By using schemabinding, we are tying to view much closer to the underlying table. This will allow for us to do some other things later
Line 25: By using `COUNT_BIG(*)`, we can do some other things later
Line 33: We are going to create a `Unique Clusted Index` on the view. That is a mouthful. Let's take each part.
- UNIQUE: If this were a table, that would mean this would be a candidate key. That is to say it could be a primary key. Views don't have primary keys, but this close.
- CLUSTERED: If this were a table, it would mean that the data physically stored in the order shown. In other words the data is going to go in by CreateDate. This is a good way to cluster this data. Everyday, we will add new data on the end as opposed to it being inserted at some random location.
- INDEX: We are creating an index on a view. If we do this right, we will never have to touch the underlying tables.

If we skip ahead to line 43, DATA_COMPRESSION: Let's think about how redundant our data is. 

- CreateDate is only the date. It will repeat over and over again for the entire day
- Endpoint is a small finite list
- Verb is a small finite list
- IP_checksum will have a certain level or redundancy

Overall, this data is very repetitive. 

### Loading data

We are going to be loading this data in the old school manner. No ORM for us. Let's take a look at the insert statement. This is a very basic T-SQL.

There is really not a lot going on here, but that was our goal. If we would have done Plan B, there would have been lots of code. We are have SQL Server do most of the work.


# Let's load up some data

Let's load up some data. I can create random endpoints and random verbs. The way I programmed it, I really can't do random user_agents and IPs. Overall this is not going to ideally random. Then again, not every endpoint has every verb.

After I load my data, I am goint to have SQL Server report on compressed space, and un compressed space on both the table and view.

The table is coming in at better than 10 to 1 radio. Very good. The view is even more impressive. It is coming it 100 to 1 radio compared to the uncompressed data.

I ran this a bunch more times after I took the screenshots, and the view seemed to stabize out at about 1000 to 1. I suspect in a production environment with random IPs and User Agents, I suspect that `dbo.traffic` would settle down to 3 to 1, and the view down to 300 to 1.


# What about getting the data
What about getting the data out of the database. The way my indexed view works, I never have to hit the underlying database. When I look at the query plan, I can see only the index on the view is used. This is a very lightweight operation.


## CPU time vs Disk IO time

As with all technology choices, using compression changes how the database operates. It puts a bigger load on CPUs because data has to be compresses and decompressed when it is written a read. Of course as it is reading from the file system, it does not have to as much Disk I0. So what is faster a disk or a bunch of CPUs? I hope everyone knows the answer to that question. If not, go look it up.

Loading the CPU more, and Disk less is in general a good idea. They only time this doesn't work out is if you data is highly variant. That is to say there is no duplication to compress out. In that particular case, the extra work to try and compress data, is wasted effort and CPU cycles.


# Final editorial comments.

There are good reasons to normalize data.




# Resources

- https://github.com/jmohler1970/DB_Compression (This document)

- https://stackoverflow.com/questions/654921/how-big-can-a-user-agent-string-get

- https://docs.microsoft.com/en-us/sql/relational-databases/data-compression/enable-compression-on-a-table-or-index?view=sql-server-2017#TsqlProcedure

- https://docs.microsoft.com/en-us/sql/relational-databases/data-compression/data-compression?view=sql-server-2017

- https://docs.microsoft.com/en-us/sql/relational-databases/views/create-indexed-views?view=sql-server-2017



