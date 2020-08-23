# TTT Discord Immersion ![Icon](https://raw.githubusercontent.com/Owningle/TTT-Discord-Immersion/master/images/icon/Icon_64x.png)

[![gmod-addon](https://img.shields.io/badge/gmod-addon-_.svg?colorB=1194EF)](https://wiki.garrysmod.com) [![discord-bot](https://img.shields.io/badge/discord-bot-_.svg?colorB=8C9EFF)](https://discord.js.org) [![license](https://img.shields.io/github/license/Owningle/TTT-Discord-Immersion.svg)](LICENSE)

This addon and Discord bot will enhance your TTT / Murder immersion. You should use this in conjunction with an in-game proximity voice chat addon such as [this one](https://steamcommunity.com/sharedfiles/filedetails/?id=2051674221). This is not meant for use in public servers, rather servers hosted for a group of friends.

This addon will deafen everyone in discord when the round starts, and undeafen users as they die. This allows people who are alive to talk via in-game proximity voice chat, and those who are dead may talk to each other, and spectate. This allows for some intense moments, as you will have no idea who has died.

Everyone on the server will have to disable the Discord Overlay, and not have Discord open on another monitor, as this will allow people to easily see who is dead. That is why this addon is not made for public servers, rather servers hosted for a group of friends.

## Getting Started
If you need any help, join my [discord server](https://discord.gg/pcuQrzq).

### Prerequisites
 - You must have a Garry's Mod server installed and set up with the TTT Gamemode.
 - You must have [Nodejs](https://nodejs.org) installed.

### Installation
1. Clone this repository and install any dependencies.
	```bash
	cd ~
	git clone https://github.com/Owningle/TTT-Discord-Immersion.git
	cd ttt_discord_bot
	npm install --prefix ./discord_bot/
	```
2. Create a Discord bot, invite him to your server, and paste the token in the config file.
	- Follow [this guide](https://github.com/reactiflux/discord-irc/wiki/Creating-a-discord-bot-&-getting-a-token) to create a bot and invite it to your server.
	- Insert the bot's token into the `discord -> token` field in the config.json file.
	- Grant the bot permission to deafen players.
3. Insert the Guild (server) ID and the channel ID in the config.json file.
	- Follow [this guide](https://support.discordapp.com/hc/en-us/articles/206346498-Where-can-I-find-my-User-Server-Message-ID-) to get the IDs
	- Insert the guild ID at  `discord -> guild`  and the channel ID of the voice channel in which the bot should deafen players at  `discord -> channel`  in the config.json file.
4. Add the addon to the Garry's Mod server.
	- Move the `gmod_addon` folder to `garrysmod/addons` and rename it to something suitable e.g. `ttt_discord_immersion`.
	- Or add the [workshop addon]() to the servers collection.
5. Add the `-allowlocalhttp` start parameter to the Garry's Mod server
    - Open the file that you run to start the Garry's Mod server, and add `-allowlocalhttp` to the line which runs the Garry's Mod server exe file (`srcds.exe`).

### Usage
 - Start the bot by running the node command in the `discord_bot` folder.
 - Connect your steam account with the bot by typing `!discord YourDiscordTag`in the in-game chat. E.g `!discord Owningle#5525`.
 - If you are in the configured voice channel, the round has started, and your connected with discord, the bot will deafen you.

## Credits
- This was based off of [ttt_discord_bot](https://github.com/marceltransier/ttt_discord_bot) but has been rewritten and heavily modified.
- [Discord.js](https://discord.js.org/) is used in this project.
- Thanks to the people supporting and developing the TTT Gamemode.

## Contributing
1. Fork it (https://github.com/Owningle/TTT-Discord-Immersion/fork)
2. Create your branch
3. Commit Changes
4. Push to branch
5. Create a new Pull Request

## License
This project is licensed under the MIT License - see the  [LICENSE](https://github.com/Owningle/TTT-Discord-Immersion/blob/master/LICENSE)  file for details.
