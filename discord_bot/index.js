const Discord = require('discord.js');
const config = require('./config.json');
const {log,error} = console;
const http = require('http');
const fs = require('fs');

const PORT = config.server.port; //unused port and since now the OFFICIAL ttt_discord_bot port ;)

var guild, channel;

var muted = {};

var get = [];

//create discord client
const client = new Discord.Client();
client.login(config.discord.token);

client.on('ready', () => {
	log('Bot is ready to Deafen them all! :)');
	guild = client.guilds.get(config.discord.guild);
//	guild = client.guilds.find('id',config.discord.guild);
	channel = guild.channels.get(config.discord.channel);
//	channel = guild.channels.find('id',config.discord.channel);
});
client.on('voiceStateUpdate',(oldMember,newMember) => {//player leaves the ttt-channel
	if (oldMember.voiceChannel != newMember.voiceChannel && isMemberInVoiceChannel(oldMember)) {
		if (isMemberMutedByBot(newMember) && newMember.serverMute) newMember.setMute(false).then(()=>{
			setMemberDeafenedByBot(newMember,false);
		});
	}
});

isMemberInVoiceChannel = (member) => member.voiceChannelID == config.discord.channel;
isMemberMutedByBot = (member) => muted[member] == true;
setMemberDeafenedByBot = (member,set=true) => muted[member] = set;

get['connect'] = (params,ret) => {
	let tag_utf8 = params.tag.split(" ");
	let tag = "";

	tag_utf8.forEach(function(e) {
		tag = tag+String.fromCharCode(e);
	});

	let found = guild.members.filterArray(val => val.user.tag.match(new RegExp('.*'+tag+'.*')));
	if (found.length > 1) {
		ret({
			answer: 1 //pls specify
		});
	}else if (found.length < 1) {
		ret({
			answer: 0 //no found
		});
	}else {
		ret({
			tag: found[0].user.tag,
			id: found[0].id
		});
	}
};

get['undeafen'] = (params, ret) => {
    let ids = params.ids;
	if (typeof ids !== 'string') {
		ret();
		return;
    }

    allIds = ids.split(",;,")
    result = true
    allIds.forEach(function(id){
        let member = guild.members.find(user => user.id === id);

        if (member) {
            if (isMemberInVoiceChannel(member)) {
                if (member.serverDeaf) {
                    member.setDeaf(false)
                    if (result) {
                    result = true
                    }
                } else{
                    setMemberDeafenedByBot(member);
                        log("undeafened: " + id + " (" + member.user.tag + ")");
                        if (result) {
                        result = true
                        }
                }
            }
        }
    });
    if (result) {
        ret({
            success: true
        });
    } else {
        ret({
            success: false,
            error: "Failed"
        });
    }
    
}

get['deafen'] = (params, ret) => {
    let ids = params.ids;
	if (typeof ids !== 'string') {
		ret();
		return;
    }

    allIds = ids.split(",;,")
    result = true
    allIds.forEach(function(id){
        let member = guild.members.find(user => user.id === id);

        if (member) {
            if (isMemberInVoiceChannel(member)) {
                if (!member.serverDeaf) {
                    member.setDeaf(true)
                    if (result) {
                    result = true
                    }

                } else{
                    setMemberDeafenedByBot(member);
                        log("deafened: " + id + " (" + member.user.tag + ")");
                        if (result) {
                        result = true
                        }
                }
            }
        }
    });
    if (result) {
        ret({
            success: true
        });
    } else {
        ret({
            success: false,
            error: "Failed"
        });
    }
}

http.createServer((req,res)=>{
	if (typeof req.headers.params === 'string' && typeof req.headers.req === 'string' && typeof get[req.headers.req] === 'function') {
		try {
			let params = JSON.parse(req.headers.params);
			get[req.headers.req](params,(ret)=>res.end(JSON.stringify(ret)));
		}catch(e) {
			res.end('no valid JSON in params');
		}
	}else
		res.end();
}).listen({
	port: PORT
},()=>{
	log('http interface is ready :)')
});