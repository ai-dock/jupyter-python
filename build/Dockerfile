# For build automation - Allows building from any ai-dock base image
ARG IMAGE_BASE="ghcr.io/ai-dock/base-image:cuda-11.8.0-base-22.04"
FROM ${IMAGE_BASE}

LABEL org.opencontainers.image.source https://github.com/ai-dock/extended-image-template

LABEL org.opencontainers.image.description "Template for images extending ai-dock/base-image"

LABEL maintainer="Rob Ballantyne <rob@dynamedia.uk>"

# Add new paths at front 
#ENV PATH=/opt/another/bin:$PATH

# Copy early so we can use scripts in the build - Changes to these files will invalidate the cache and cause a rebuild.
COPY ./COPY_ROOT/ /

ARG PYTHON_VERSION
ARG PYTHON_MAMBA_NAME

# Use build scripts to ensure we can build all targets from one Dockerfile in a single layer.
# Don't put anything heavy in here - We can use multi-stage building above if necessary.
RUN bash -c /opt/ai-dock/bin/build/layer0/init.sh

# Keep these as-is. Place additional logic in /opt/ai-dock/bin/preflight.sh
ENTRYPOINT [ "entrypoint.sh" ]

CMD ["supervisord-init.sh"]
