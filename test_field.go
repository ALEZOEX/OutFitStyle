package main

import "outfitstyle/server/internal/config"

func main() {
    cfg := config.AppConfig{}
    _ = cfg.Push.APNBundleID
}