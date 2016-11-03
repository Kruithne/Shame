== Shame ==

**Please note this add-on was created with the primary intention of being used by my guild. It is not designed to be user-friendly nor intended for users with little add-on experience. This page covers everything you need to know.**

This project is open-source and maintained on GitHub here: https://github.com/Kruithne/Shame

This add-on is intended to track avoidable fails that your group and guild make in a leader-board fashion.

**This add-on requires WeakAuras 2 in order to work**

**Default triggers bundled with this add-on will only work on English clients. If you need them to work on a different localization, please modify them or create your own triggers.**

=== Frequently Asked Questions ===
* **How do I install this?** - Check the Installing/Usage section on this page.
* **
* **Why is WeakAuras2 required?** - We took the approach of using WeakAuras2 to trigger the shame to allow in-game customization of the triggers on-the-fly without needing to re-code or reload anything. It also allows for people to share their own triggers to work with this add-on without us releasing and maintaining them.
* **Do I need to install every single aura in the folders?** - No. If you're after, for example, the Halls of Valor dungeon, just import the text inside Shame_7D_HV. Every aura has a folder with it which contains the auras split up and in Lua form; this is for development purposes (or if you just want one specific trigger, for some reason).
* **Something doesn't give Shame and I think it should...** - Create a WeakAura to trigger Shame. Check the default ones for a reference on how to do that. If you think it's awesome, feel free to submit it as a PR to the GitHub project and if it's good, we'll bundle it with the add-on.
* **This add-on spams too much!** - You can mute the output, check the command reference.
* **There's no aura file for...?** - We only create aura files for encounters we'll be running on a serious level in our dungeon group. It also takes us a while to gather the needed information to properly distribute shame for certain encounters, so there may be a delay on new content. Feel free to create your own encounter triggers and share them on the GitHub page as a PR.

=== Installing/Usage ===
# Ensure you have this add-on and the WeakAuras2 add-on installed and updated.
# Load up World of Warcraft.
# Locate the 'auras' folder inside the 'Shame' add-on directory.
# Each zone that you wish to use must be imported; locate which one you would like. (A full list of names and their associated aura file can be located at the bottom of this page).
# Open the aura file in a text editor and copy all of the contents.
# In-game, open WeakAuras (/wa) and select the "Import" option.
# Paste the data you just copied from the file and import it.
# Repeat steps 4-7 for each dungeons/raid/etc you want to monitor.
# Check the command reference to see how to control the Shame.

=== Commands ===

* /shame start - Start monitoring people's shame.
* /shame stop - Stop monitoring people's shame.
* /shame mode [mode] [channel] - Set the mode of real-time output for shaming.
* /shame print [channel] - Print the current session leader-board.
* /shame help - List commands available.

**mode**
* all - Every real-time shame event will be broadcast to the specified channel.
* self - Real-time shame events will only be broadcast in your chat log.
* silent - No real-time events will be broadcast

**channel**
* Available options: guild, officer, party, instance, raid

=== Supported Things ===

-*Halls of Valor (Shame_7D_HV)*