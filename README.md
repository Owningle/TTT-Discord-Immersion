# TTT Discord Immersion ![Icon](https://raw.githubusercontent.com/Owningle/TTT-Discord-Immersion/master/images/icon/Icon_64x.png)

[![gmod-addon](https://img.shields.io/badge/gmod-addon-_.svg?colorB=1194EF)](https://wiki.garrysmod.com) [![discord-bot](https://img.shields.io/badge/discord-bot-_.svg?colorB=8C9EFF)](https://discord.js.org) [![license](https://img.shields.io/github/license/Owningle/TTT-Discord-Immersion.svg)](LICENSE)

This addon and Discord bot will enhance your TTT / Murder immersion. You should use this in conjunction with an in-game proximity voice chat addon such as [this one](https://steamcommunity.com/sharedfiles/filedetails/?id=2051674221). This is not meant for use in public servers, rather servers hosted for a group of friends.

This addon will deafen everyone in discord when the round starts, and undeafen users as they die. This allows people who are alive to talk via in-game proximity voice chat, and those who are dead may talk to each other, and spectate. This allows for some intense moments, as you will have no idea who has died.

Everyone on the server will have to disable the Discord Overlay, and not have Discord open on another monitor, as this will allow people to easily see who is dead. That is why this addon is not made for public servers, rather servers hosted for a group of friends.

## Getting Started
If you need any help, join my [discord server](https://discord.gg/pcuQrzq).

### Prerequisites
 - You must have a Garry's Mod server installed and set up with the TTT Gamemode.

### Installation
1. Install CHTTP on the server. (https://github.com/timschumi/gmod-chttp)
1. Clone/Download this repository, one of the follwing.
	- ```git clone https://github.com/Owningle/TTT-Discord-Immersion.git```
	- Clicking the dropdown for `Code` and then clicking `Dowload as Zip`
2. Create a Discord bot, invite it to your server, and set the token for the addon.
	- Follow [this guide](https://github.com/Owningle/TTT-Discord-Immersion/wiki/Creating-a-Discord-Bot) to create a bot and invite it to your server.
	- Set the convar `discord_token` to your bots token.
	- Grant the bot permission to deafen and mute members.
3. Set the server ID.
	- Follow [this guide](https://support.discordapp.com/hc/en-us/articles/206346498-Where-can-I-find-my-User-Server-Message-ID-) to get the IDs
	- Set the convar `discord_guild` to your server's ID.
5.  Add an addon to enable proximity voice chat in game.
    - I reccomend [this one](https://steamcommunity.com/sharedfiles/filedetails/?id=2051674221).

### Usage
 - The convar `discord_enabled` enables (1) / disables (0) the bot.
 - Connect your steam account with the bot by typing `!discord YourDiscordTag`in the in-game chat. E.g `!discord Owningle#5525`.
 - If you are in a voice channel, the round has started, and your connected with discord, the bot will deafen you.

## Credits
- [ttt_discord_bot](https://github.com/marceltransier/ttt_discord_bot) This was a huge help for the first version of this addon.
- Thanks to the people supporting and developing the TTT Gamemode.

## Contributing
1. Fork it (https://github.com/Owningle/TTT-Discord-Immersion/fork)
2. Create your branch
3. Commit Changes
4. Push to branch
5. Create a new Pull Request

## License
This project is licensed under the MIT License - see the  [LICENSE](https://github.com/Owningle/TTT-Discord-Immersion/blob/master/LICENSE)  file for details.
