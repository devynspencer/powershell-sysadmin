# Sysadmin Module
Automate sysadmin tasks. Simplify work. Profit.

## Configuration data
Much if not all of this module is intended to run off of JSON data describing an infrastructure. This provides a source-controllable, explicit record of how the infrastructure should look/work/function.

An example of what is in use currently:

```json
{
  "servers": [
    {
      "hostname": "srv01",
      "roles": [],
      "site": "Foxtrot"
    },
    {
      "hostname": "prn01",
      "roles": ["print"],
      "site": "Zulu"
    },
    {
      "hostname": "prn02",
      "roles": ["print"],
      "site": "Charlie"
    }
  ]
}
```

## Install
Install from GitHub source:

```powershell
git clone 'https://github.com/devynspencer/powershell-sysadmin'
cd .\powershell-sysadmin
```
