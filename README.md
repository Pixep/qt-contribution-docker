Run with `--privileged` or `--security-opt seccomp:unconfined` to allow GDB to work correctly.

```
docker run -d -p 5901:5901 -p 6901:6901 --privileged qt-contrib:0.2
```
