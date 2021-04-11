#    MissJuliaRobot (A Telegram Bot Project)
#    Copyright (C) 2019-Present Anonymous (https://t.me/MissJulia_Robot)

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, in version 3 of the License.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.

#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see < https://www.gnu.org/licenses/agpl-3.0.en.html >


from julia import tbot
from pymongo import MongoClient
from julia import MONGO_DB_URI, OWNER_ID
from telethon import events, types
from datetime import datetime, timedelta
import asyncio

# Made by @MissJulia_Robot


def get_time(id):
    client = MongoClient(MONGO_DB_URI)
    db = client["missjuliarobot"]
    spammers = db.spammer
    return spammers.find_one({"id": id})
    
def get_expiry(id):
    client = MongoClient(MONGO_DB_URI)
    db = client["missjuliarobot"]
    leechers = db.leecher
    return leechers.find_one({"id": id})


@tbot.on(events.NewMessage(pattern=None))
async def spammers(event):
    if str(event.sender_id) in str(OWNER_ID):
        return
    sender = event.sender_id
    senderr = await event.get_sender()
    msg = str(event.text)
    if not msg.startswith("/"):
       return

    client = MongoClient(MONGO_DB_URI)
    db = client["missjuliarobot"]
    spammers = db.spammer
    leechers = db.leecher    

    users = spammers.find({})
    for c in users:
        if sender == c["id"]:            
            to_check = get_time(id=sender)
            mongoid = to_check["_id"]
            idiot = to_check["id"]
            starttime = to_check["stime"]
            count = to_check["count"]
            lastmsg = to_check["lastmsg"]   
            expiry = datetime.now() + timedelta(days=1)

            # maximum time for which the last message should be triggered
            # after n seconds it releases the lock 
            if (count >= 1 and sender == idiot and int(((datetime.now() - starttime)).total_seconds()) >= 10):
               spammers.update_one(
                {
                    "_id": mongoid,
                    "id": idiot,
                    "stime": starttime,
                    "count": count,
                    "lastmsg": lastmsg, 
                },
                {"$set": {"count": 1, "stime": datetime.now(), "lastmsg": msg}},          
               )
               return
            if (
                 count >= 4
                 and sender == idiot
                 and int(((datetime.now() - starttime)).total_seconds()) <= 3                       
            ) or (
                 count >= 4 and sender == idiot and msg == lastmsg
            ): 
              if senderr.username is None:
                 pow = leechers.find({})
                 for z in pow:
                   if sender == z["id"]:            
                       return
                 st = senderr.first_name
                 hh = senderr.id
                 final = f"[{st}](tg://user?id={hh}) you are detected as a spammer according to my algorithms.\nYou will be restricted from using any bot commands for 24 hours !"          
                 await tbot.send_message(hh, final)
                 spammers.delete_one({"id": hh})
                 leechers.insert_one({"id": hh, "time": expiry})
                 return
              else:
                 pow = leechers.find({})
                 for z in pow:
                   if sender == z["id"]:            
                       return
                 st = senderr.username
                 hh = senderr.id
                 final = f"@{st} you are detected as a spammer according to my algorithms.\nYou will be restricted from using any bot commands for 24 hours !"
                 await tbot.send_message(hh, final)
                 spammers.delete_one({"id": hh})
                 leechers.insert_one({"id": hh, "time": expiry})
                 return              
            spammers.update_one(
                {
                    "_id": mongoid,
                    "id": idiot,
                    "stime": starttime,
                    "count": count,
                    "lastmsg": lastmsg, 
                },
                {"$set": {"count": count + 1, "stime": datetime.now()}},
            )
            return
          
    spammers.insert_one({"id": sender, "stime": datetime.now(), "count": 1, "lastmsg": msg})    


@tbot.on(events.NewMessage(pattern=None))
async def spammers(event):
    client = MongoClient(MONGO_DB_URI)
    db = client["missjuliarobot"]
    leechers = db.leecher    
    users = leechers.find({})
    for c in users:
        if event.sender_id == c["id"]:
            to_check = get_expiry(id=event.sender_id)
            ttime = to_check["time"]            
            if int(((datetime.now() - ttime)).total_seconds()) > 86400:
                leechers.delete_one({"id": event.sender_id})
                return
            else:
                return
