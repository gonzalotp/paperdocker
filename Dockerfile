########################################################
############## We use a java base image ################
########################################################
#FROM openjdk:8-alpine
FROM openjdk:11-jre-slim

ARG paperspigot_ci_url=https://papermc.io/api/v1/paper/${PAPER_VERSION}/latest/download
ENV PAPERSPIGOT_CI_URL=$paperspigot_ci_url

WORKDIR /opt/minecraft

# Download paper
ADD ${PAPERSPIGOT_CI_URL} paperclip.jar

# Build paper
RUN chmod go+r /opt/minecraft -R && java -jar /opt/minecraft/paperclip.jar; exit 0

# Copy built jar
RUN mv /opt/minecraft/cache/patched*.jar paperspigot.jar \
&& rm /opt/minecraft/cache/* \
&& rm paperclip.jar

# Working directory
# Worlds, logs, config and plugins will be here
VOLUME /data
WORKDIR /data

# Entrypoint
# Using exec to make java replace the parent process
ENTRYPOINT exec java -jar -Xms$MEMORYSIZE -Xmx$MEMORYSIZE -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=100 -XX:+DisableExplicitGC -XX:TargetSurvivorRatio=90 -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:G1MixedGCLiveThresholdPercent=35 -XX:+AlwaysPreTouch -XX:+ParallelRefProcEnabled -Dusing.aikars.flags=mcflags.emc.gs -Dcom.mojang.eula.agree=true /opt/minecraft/paperspigot.jar
