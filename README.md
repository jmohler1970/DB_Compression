# Introduction

I am going to argue against data normalization and I am going to be using traffic tracking as an example


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

I do have the create script for this, but it is easier if I just show a diagram of a normalized version of this. We have four tables all with foreign key relationships to the main table


### Rule of thumb

One of my rules of thumb is to assume that any given system  will be around 10 years later. I will be collecting all this data. Do I really want to keep `Endpoint_Enhanced`, `IP_Enhanced`, `Verb_Enhanced`, and `User_Agent_Enhanced` with all of their valid values for 10 years? Won't some of this data be obsolete?

There is no clean way to scrub this data. I expect that a lot IP and User_Agent information will be highly useless in 10 years.


### about the CFCs

Now let's think about the CFCs that would be needed for this... all five of them. Sometimes the will have to inserts on the outlying tables. Sometimes they will have to do selects. Plan A for all of its problems, entailed only one insert operation. Between detecting and conditionally inserting, this is going to have a lot database interactions. I have only included the build scripts in Github. This is just too much to build out. 



## Plan C

Let's go back to plan A and do some cleanup. First off my data is too long. I don't really need IP. I just need to know how many unique IPs there are. So let's just save a `CHECKSUM()` of that. 

`User_Agent` can be very long. I have heard up to 16k. I don't want to save all that. I am just going to cut it off at 255 characters.

Now we are going to do some serious reduction. We are going to build the table with  compression.

```
WITH (DATA_COMPRESSION = PAGE);
```

So how this type of compression work? It will do the following:
- It is going to look for redundant data in the same row (I don't expect much of this)
- It is going to look for redundant data in the start of string (`User_Agent` and `endpoint` are going to have a little of this.)
- It is going to look for redandant data across rows. (There is going to be a lot of this)

Anytime it sees `endpoint` or `verb` or `ip_hash` or `user_agent` repeating, it will just save a reference to it. It does not physically save the string. I am expecting a 3 to 1 to a 10 to 1 compression ratio out of this. 

### Now with view

I am going to create a view too, but this is not a normal view.

I collect data as traffic come in, but it is very common to evaluate data on a daily basis. I don't want to even touch `dbo.Traffic`, if I don't have to. Here is what we are going to do with the view

Line 22: By using schemabinding, we are tying to view much closer to the underlying table. This will allow for us to do some other things later
Line 25: By using `COUNT_BIG(*)`, we can do some other things later
Line 33: We are going to create a Unique Clusted Index on the view


### CPU time vs Disk IO time

As with all technology choices, using compression changes how teh database operates. It puts a bigger load on CPUs because data has to be compresses and decompressed when it is written a read. Of course as it is reading from the file system, it does not have to as much Disk I0. So what is faster a disk or a bunch of CPUs? I hope everyone knows the answer to that question. If not, go look it up.

Loading the CPU more, and Disk less is in general a good idea. They only time this doesn't work out is if you data is highly variant. That is to say there is no duplication to compress out. In that particular case, the extra work to try and compress data, is wasted effort and CPU cycles.



# Let's check our results

EXEC sp_estimate_data_compression_savings 'dbo', 'Traffic_C', NULL, NULL, 'NONE' ;  
GO 

EXEC sp_estimate_data_compression_savings 'dbo', 'vwTraffic_C', NULL, NULL, 'NONE' ;  
GO 


# Resources

- https://stackoverflow.com/questions/654921/how-big-can-a-user-agent-string-get
