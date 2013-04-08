# Pushes
GitHub post-commit notifs in your OS X Notification Center

## Installation
```
gem install pushes
```

## Commands
### Fetch (Default)
Single call to GitHub API.
```sh
$ pushes
$ pushes fetch
```

### Start
Start a LaunchAgent background process.<br>
Will `fetch` every `INTERVAL` seconds and will start at load.
```sh
$ pushes start
$ pushes start 30
$ pushes start INTERVAL
```

### Stop
Stop the background process and delete the LaunchAgent file.
```sh
$ pushes stop
```

## License
Copyright © 2012 Heliom. See [LICENSE](/LICENSE.md) for details.
