<p align="center">
  <strong>GitHub post-commit notifs<br>in your OS X Notification Center</strong><br>
  <img src="https://f.cloud.github.com/assets/436043/928820/ea544eee-ffc2-11e2-8604-cf49744c8118.png" alt="Pushes">
</p>

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
Will `fetch` every `INTERVAL` seconds (default: 10) and will start at boot.
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
