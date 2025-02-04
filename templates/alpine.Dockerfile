FROM {{ .Image }}

USER root

RUN apk update --no-cache && \
    apk add \
      util-linux \
      linux-virt \
      busybox-initscripts \
      openrc

#RUN apk update --no-cache && \
#    apk add \
#      linux-virt \
#      alpine-base \
#      openssh-server

RUN for s in bootmisc hostname hwclock modules networking swap sysctl urandom syslog; do rc-update add $s boot; done
RUN for s in devfs dmesg hwdrivers mdev; do rc-update add $s sysinit; done


RUN echo "root:{{- if .Password}}{{ .Password}}{{- else}}root{{- end}}" | chpasswd

