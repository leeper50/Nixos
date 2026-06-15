{ lib, ... }:
let
  defaultCalendarSettings = {
    remote = {
      type = "caldav";
      userName = "wleeper@mailbox.org";
    };
    thunderbird = {
      enable = true;
      profiles = [ "default" ];
    };
  };
  defaultContactSettings = {
    remote = {
      type = "carddav";
      userName = "wleeper@mailbox.org";
    };
    thunderbird = {
      enable = true;
      profiles = [ "default" ];
    };
  };
  defaultEmailSettings = {
    enable = true;
    realName = "Walter Leeper";
    thunderbird = {
      enable = true;
      profiles = [ "default" ];
    };
  };
  gmailSettings = defaultEmailSettings // {
    imap = {
      authentication = "xoauth2";
      host = "imap.gmail.com";
      port = 993;
      tls.enable = true;
    };
    smtp = {
      authentication = "xoauth2";
      host = "smtp.gmail.com";
      port = 465;
      tls.enable = true;
    };
  };
  mailboxSettings = defaultEmailSettings // {
    imap = {
      host = "imap.mailbox.org";
      port = 993;
      tls.enable = true;
    };
    smtp = {
      host = "smtp.mailbox.org";
      port = 465;
      tls.enable = true;
    };
  };
  outlookSettings = defaultEmailSettings // {
    imap = {
      authentication = "xoauth2";
      host = "outlook.office365.com";
      port = 993;
      tls.enable = true;
    };
    smtp = {
      authentication = "xoauth2";
      host = "smtp-mail.outlook.com";
      port = 587;
      tls = {
        enable = true;
        useStartTls = true;
      };
    };
  };
in
{
  accounts.calendar.accounts = {
    "Birthdays" = lib.recursiveUpdate defaultCalendarSettings {
      remote.url = "https://dav.mailbox.org/caldav/Y2FsOi8vMS8w";
      thunderbird.color = "#be6217";
    };
    "Personal" = lib.recursiveUpdate defaultCalendarSettings {
      remote.url = "https://dav.mailbox.org/caldav/Y2FsOi8vMC8zMg";
      thunderbird.color = "#dc8add";
    };
  };
  accounts.contact.accounts = {
    "Contacts" = lib.recursiveUpdate defaultContactSettings {
      remote.url = "https://dav.mailbox.org/carddav/33";
    };
    "Personal" = lib.recursiveUpdate defaultContactSettings {
      remote.url = "https://dav.mailbox.org/carddav/44";
    };
  };
  accounts.email.accounts = {
    "Mailbox" = mailboxSettings // {
      address = "wleeper@mailbox.org";
      imap = {
        host = "imap.mailbox.org";
        port = 993;
        tls.enable = true;
      };
      primary = true;
      smtp = {
        host = "smtp.mailbox.org";
        port = 465;
        tls.enable = true;
      };
      userName = "wleeper@mailbox.org";
    };
    "Gmail" = gmailSettings // {
      address = "wleeper49@gmail.com";
      userName = "wleeper49@gmail.com";
    };
    "Outlook - Personal" = outlookSettings // {
      address = "wleeper49@hotmail.com";
      userName = "wleeper49@hotmail.com";
    };
    "Outlook - Misc" = outlookSettings // {
      address = "wleeper50@hotmail.com";
      userName = "wleeper50@hotmail.com";
    };
    "Outlook - Work" = outlookSettings // {
      address = "wleeper13@outlook.com";
      userName = "wleeper13@outlook.com";
    };
  };
  programs.thunderbird = {
    enable = true;
    profiles = {
      "default" = {
        isDefault = true;
        search = {
          default = "ddg";
          privateDefault = "ddg";
        };
      };
    };
    settings = {
      "general.autoScroll" = true;
      "general.useragent.override" = "";
      "mail.biff.play_sound" = false;
      "mail.shell.checkDefaultClient" = false;
      "mail.spam.manualMark" = true;
      "mail.spam.markAsReadOnSpam" = true;
      "mail.ui.folderpane.view" = 6;
      "mailnews.message_display.disable_remote_image" = false;
      "mailnews.start_page.enabled" = false;
      "network.cookie.cookieBehavior" = 1;
      "privacy.donottrackheader.enabled" = true;
    };
  };

  # Thunderbird file cleanup
  home.activation.removeThunderbirdSearch = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    rm -f "$HOME/.thunderbird/default/search.json.mozlz4"
    rm -f "$HOME/.thunderbird/default/search.json.mozlz4.home_manager_backup"
  '';
}
