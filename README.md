<p align="center">
  <strong>GitHub post-commit notifs<br>in your OS X Notification Center</strong><br>
  <img src="https://f.cloud.github.com/assets/436043/928820/ea544eee-ffc2-11e2-8604-cf49744c8118.png" alt="Pushes"><br>
  <a href="http://badge.fury.io/rb/pushes"><img src="https://badge.fury.io/rb/pushes@2x.png" alt="Gem Version" height="18"></a>
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
Will `fetch` every `INTERVAL` seconds (default: 10) and will restart at boot.
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

### Reset
Clear commits storage. We noticed Pushes doesn’t play too well with a force push that removes commits even though such action should be prohibited. In any case, you may want to reset your local storage.
```sh
$ pushes reset
```

## License
Copyright © 2013 Heliom. See [LICENSE](/LICENSE.md) for details.
