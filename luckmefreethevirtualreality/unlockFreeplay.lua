function onEndSong()
    runHaxeCode([[
        import backend.ClientPrefs;

        ClientPrefs.data.freeplayUnlock = true;
        ClientPrefs.saveSettings();
     ]])
end