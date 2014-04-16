FROM hachque/opensuse

RUN zypper mr -e openSUSE_13.1_OSS
RUN zypper mr -e openSUSE_13.1_Updates
RUN zypper ref
RUN zypper --non-interactive in nginx

EXPOSE 80
EXPOSE 443

