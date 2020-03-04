﻿using AdysTech.CredentialManager;
using Newtonsoft.Json;
using Serilog;
using System;
using System.Net;
using XIVLauncher.Addon.Implementations.XivRichPresence;

namespace XIVLauncher.Accounts
{
    public class XivAccount
    {
        [JsonIgnore]
        public string Id => $"{UserName}-{UseOtp}-{UseSteamServiceAccount}";

        public string UserName { get; private set; }

        [JsonIgnore]
        public string Password
        {
            get
            {
                var credentials = CredentialManager.GetCredentials($"FINAL FANTASY XIV-{UserName}");

                return credentials != null ? credentials.Password : string.Empty;
            }
            set => CredentialManager.SaveCredentials($"FINAL FANTASY XIV-{UserName}", new NetworkCredential
            {
                UserName = UserName,
                Password = value
            });
        }

        public bool SavePassword { get; set; }
        public bool UseSteamServiceAccount { get; set; }
        public bool UseOtp { get; set; }

        public string ChosenCharacterName;
        public string ChosenCharacterWorld;

        public string ThumbnailUrl;

        public XivAccount(string userName)
        {
            UserName = userName;
        }

        public string FindCharacterThumb()
        {
            if (string.IsNullOrEmpty(ChosenCharacterName) || string.IsNullOrEmpty(ChosenCharacterWorld))
                return null;

            try
            {
                dynamic searchResponse = XivApi.GetCharacterSearch(ChosenCharacterName, ChosenCharacterWorld)
                .GetAwaiter().GetResult();

                if (searchResponse.Results.Count > 1) //If we get more than one match from XIVAPI
                {
                    foreach (var AccountInfo in searchResponse.Results)
                    {
                        //We have to check with it all lower in case they type their character name LiKe ThIsLoL. The server XIVAPI returns also contains the DC name, so let's just do a contains on the server to make it easy.
                        if (AccountInfo.Name.Value.ToLower() == ChosenCharacterName.ToLower() && AccountInfo.Server.Value.ToLower().Contains(ChosenCharacterWorld.ToLower()))
                        {
                            return AccountInfo.Avatar.Value;
                        }
                    }
                }

                return searchResponse.Results.Count > 0 ? (string)searchResponse.Results[0].Avatar : null;
            }
            catch (Exception ex)
            {
                Log.Information(ex, "Couldn't download character search.");

                return null;
            }
        }
    }
}