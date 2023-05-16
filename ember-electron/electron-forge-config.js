const path = require('path');

module.exports = {
  "make_targets": {
    "win32": [
      "squirrel"
    ],
    "darwin": [
      "dmg",
      "zip"
    ],
    "linux": [
      "deb",
      "rpm"
    ]
  },
  "electronPackagerConfig": {
    "appCopyright": "Copyright (C) 2017 Draios inc.",
    "name": "Nextlinux Inspect",
    "versionString": {
        "CompanyName": "Nextlinux",
        "FileDescription": "Nextlinux Inspect for Desktop",
        "ProductName": "Nextlinux Inspect",
        "InternalName": "Nextlinux Inspect"
    },
    "icon": "assets/icons/favicon",
    "osxSign": true,
    "overwrite": true
  },
  "electronWinstallerConfig": {
    "title": "Nextlinux Inspect",
    "name": "NextlinuxInspect",
    "description": "A powerful opensource interface for container troubleshooting and security investigation",
    "iconUrl": `https://raw.githubusercontent.com/nextlinux/nextlinux-inspect/win-integration/assets/icons/favicon.ico`,
    "setupIcon": path.join(__dirname, '../assets/icons/favicon.ico'),
    "loadingGif": path.join(__dirname, '../assets/win/loading.gif'),
    "noMsi": true
  },
  "electronInstallerDMG": {
    "title": "Nextlinux Inspect",
    "background": "assets/dmg/installer-background.png",
    "icon-size": 80
  },
  "electronInstallerDebian": {
    src: '...',
    dest: '...',
    name: 'nextlinux-inspect',
    bin: 'Nextlinux Inspect'
  },
  "electronInstallerRedhat": {
    src: '...',
    dest: '...',
    name: 'nextlinux-inspect',
    bin: 'Nextlinux Inspect'
  },
  "github_repository": {
    "owner": "nextlinux",
    "name": "nextlinux-inspect"
  }
};
