#! /usr/bin/env python3
import os
from pathlib import Path
import subprocess
import sys

from gi.repository import GLib
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop

DBusGMainLoop(set_as_default=True)

objpath = "/ssh"
iface = "org.kde.krunner1"


class Runner(dbus.service.Object):
    def __init__(self, terminal_command):
        self.terminal_command = terminal_command

        dbus.service.Object.__init__(self, dbus.service.BusName("com.selfcoders.ssh-runner", dbus.SessionBus()), objpath)

    @dbus.service.method(iface, out_signature="a(sss)")
    def Actions(self, msg):
        return []

    @dbus.service.method(iface, in_signature="s", out_signature="a(sssida{sv})")
    def Match(self, query):
        query = query.split(" ")
        if len(query) > 1 and query[0] == "ssh":
            query = query[1:]

        query = " ".join(query)

        known_hosts_file = os.path.join(os.path.expanduser("~"), ".ssh", "known_hosts")
        if not os.path.isfile(known_hosts_file):
            return []

        results = []

        with open(known_hosts_file, "r") as file:
            for line in file:
                hostname = line.split(" ")[0].split(",")[0]

                if not hostname.startswith(query):
                    continue

                # actionId, actionName, iconName, Type, relevance (0-1), properties
                results.append((hostname, hostname, "terminal", 100, 0, {}))

        return results

    @dbus.service.method(iface, in_signature="ss")
    def Run(self, matchId, actionId):
        subprocess.call(self.terminal_command.format(matchId), shell=True)

def get_terminal_config():
    xdg_config_home = Path(os.environ.get('XDG_CONFIG_HOME', Path.home() / '.config'))
    config_file_path = xdg_config_home / "krunner-ssh"

    try:
        return config_file_path.read_text().strip()
    except (FileNotFoundError, PermissionError, IOError):
        return "konsole -e ssh '{}'"

if __name__ == "__main__":
    terminal_command = get_terminal_config()

    if len(sys.argv) > 1:
        terminal_command = sys.argv[1:]

    runner = Runner(terminal_command)
    loop = GLib.MainLoop()
    loop.run()
