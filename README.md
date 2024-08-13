Make termux to root user linux fully automated

run this on termux

```
pkg install wget && wget https://github.com/opiran-club/root-termux/setup.sh && chmod +x setup.sh && ./setup.sh
```

after that you have fresh ubuntu 

```
apt update && apt upgrade -y
```
and

run opiran optimizer to install all necessary packages.

```
apt install curl -y && bash <(curl -s https://raw.githubusercontent.com/opiran-club/VPS-Optimizer/main/optimizer.sh --ipv4)
```
