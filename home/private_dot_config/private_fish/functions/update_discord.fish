function update_discord
    curl -sL "https://discord.com/api/download/stable?platform=linux&format=deb" -o /tmp/discord.deb &&
        sudo dpkg -i /tmp/discord.deb &&
        sudo rm /tmp/discord.deb
end
