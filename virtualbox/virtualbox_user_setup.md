# Install on VirtualBox

This document details the requirements and steps needed to be able to run the
[`gds_env`](https://github.com/darribas/gds_env/) as a virtual machine (VM) on
VirtualBox.

## Requirements

This tutorial assumes the following is available before start:

- [VirtualBox](https://www.virtualbox.org/) downloaded and installed
- A copy of an `.ova` file containing the GDS image. [This online
  folder](https://www.dropbox.com/sh/24ehjlwgcjzepeb/AACEVD0IJ9aNj2gpbYmRpAnUa?dl=0) 
  contains available files.
  Please note this is a large file so download will take a while and will
  require a good internet connection

## Installation

There are three main steps to follow:

1. [Import the appliance (`.ova` file)](#Appliance-import)
1. [Forward the required port to the host](#Port-forwarding)
1. [Set up a shared folder so the VM can see files in your host
   machine](#Folder-sharing)

Mac users, please check the section on [known issues](#Mac-known-issues).

It's important to note these three steps are required to run only once, when
setting the VM up in a machine for the first time. Once ready, [launching and running the
VM](#Running-the-VM) is a one-click job.

### Appliance import

1. Go to "File --> Import Appliance..."
1. Select the `.ova` file you have downloaded. The import process might take a
couple of minutes, but you do not have to do anything

### Port forwarding

The VM will be accessed through your browser. To be able to connect from the
host, the port 8888 needs to be able to reach the VM. Here is how you can do
it:

1. Right click on the `gdsbox` image and then left-click on "Settings"
2. Go to the "Network" tab and click on "Advanced"
3. Click on "Port Forwarding", this will open up a new dialog window
4. On the right side, click on "Add new port" button, the one with a + sign.
If you hover your mouse over, it will read "Adds new port fordwarding rule". This will add a new row in the table
5. In the new row, type  "jupyter" under "Name", leave "Protocol", "Host IP"
and "Guest IP" as they are, and enter 8888 under both "Host Port" and "Guest
Port".
6. Then click OK on the bottom right part of the dialog window

### Folder sharing

The following steps allow you to select a folder on the host that will be
accessible from the VM.

1. Right click on the `gdsbox` image and left-click on "Settings"
2. Go to the "Shared Folders" tab
3. Click on the button that has a folder with a + sign icon. If you hover your
mouse it will read "Add new shared folder" in the top right
4.  Click on "Folder Path" and select "Other" from the folder path dropdown
5. Point to the folder you want to share with the VM
5. Use "rancheros" under the "Folder Name" box
6. Leave "Mount point" blank and make sure "Auto-mount" and "Read-only" are
*not* checked

### Mac known issues

If you are going over this process on a modern Mac, you will need to allow
VirtualBox access rights when it requests them.

Additionally, you might encounter the following error when importing the
appliance:

```
Nonexistent host networking interface, name '' (VERR_INTERNAL_ERROR).


Result Code:
NS_ERROR_FAILURE (0x80004005)

Component:
ConsoleWrap

Interface:
IConsole {872da645-4a9b-1727-bee2-5585105b9eed}
```

This has to do with security settings of macOS. To work around the issue,
follow these steps:

1. From the main menu, select "File > Host Network Manager". You should see
an empty white box with "Host-only Networks".
1. Click the "Create" button. A new Host-only network will be created and
added to the list automatically.

## Running the VM

Once the steps above are followed, you are good to go. To start a session,
follow these steps:

1. Select `gdsbox` on the VirtualBox window
1. On the top row, click on "Start"
1. A new window will launch with a black console that will start printing
output out. This should continue for about 30 seconds, depending on your
laptop
1. When it stops, you should see a [Texas
longhorn](https://en.wikipedia.org/wiki/Texas_Longhorn) drawn on the console.
Everything is ready.
1. Open a browser (Firefox or Chrome preferably) and point it at
`localhost:8888`
1. A page will load, asking you to enter a password. Use `geods`.
1. The main JupyterLab interface should load, happy hacking!

### Shared files

The file menu on the left side of JupyterLab should display a single folder
named `work`. This is the bridge to the host. If you double click on it, it
will display the files in the folder you have decided to share with
VirtualBox.
