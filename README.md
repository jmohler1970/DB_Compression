# Introduction

I want to store traffic information on my database. In particular I want to store

- CreateDate: When a request came in
- Endpoint: What was requested. I have about 10 to 15 endpoints
- Verb: What verb was used
- IP: I am going to use IPs to track the number of visitors. I am not going to worry about firewalls and things like that.
- User_agent: I want to know what kind of a browswer or requestor is being used 


# Working the problem


## Approach A

The first easy approach is just save the data along with a Identity to be the primary key. I am concerned how wide these columns are. I don't think this is going to be space efficient.



## Approach B


### Rule of thumb

One of my rules of thumb is to assume that any given system I work on will be around 10 years later. I will be collecting all this data. Do I really want to keep `Endpoint_Enhanced`, `IP_Enhanced`, `Verb_Enhanced`, and `User_Agent_Enhanced` with all of their valid values for 10 years? Won't some of this data be obsolete?

There is no clean way to scrub this data. I expect that IP and User_Agent information will be highly useless in 10 years.


## Approach C

Let's go back to A and do some cleanup. First off my data is too long. I don't really need IP. I just need to know how many unique IPs there are. So let's just save a `CHECKSUM` of that. 

`User_Agent` can be very long. I have heard up to 16k. I don't want to save all that. I am just going to cut it off at 255 characters.

Now we are going to do some serious reduction. We are going to rebuild the table with TSQL PAGE compression.

```
ALTER TABLE dbo.Traffic_C REBUILD PARTITION = ALL  
WITH (DATA_COMPRESSION = PAGE);
GO
```

This is going to do the following:
- It is going to look for redundant data in the same row (I don't expect much of this)
- It is going to look for redundant data in the start of string (`User_Agent` and `endpoint` are going to have a little of this.)
- It is going to look for redandant data across rows. (There is going to be a lot of this)

Anytime it sees `endpoint` or `verb` or `ip_hash` or `user_agent` repeating, it will just save a reference to it. It does not physically save the string. I am expecting a 3 to 1 to a 10 to 1 compression ratio out of this. 


### CPU time vs Disk IO time



## Now with views

I am going to create a view too 

# Resources

- https://stackoverflow.com/questions/654921/how-big-can-a-user-agent-string-get
