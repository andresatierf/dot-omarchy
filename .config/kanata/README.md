### Kanata service

Sync config files

```sh
cd .config/kanata
sudo stow -t /etc/systemd/system -v . # use -n to preview
```

Make sure changes are picked up

```sh
sudo systemctl daemon-reload
```

```sh
sudo systemctl restart kanata
```
