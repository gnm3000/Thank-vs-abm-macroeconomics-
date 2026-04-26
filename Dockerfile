FROM rocker/r-ver:4.3.3

RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages(c('shiny','bslib','plotly','igraph','dplyr','tidyr','purrr','yaml','viridis'), repos='https://cloud.r-project.org')"

WORKDIR /app
COPY app ./app

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/app/app', host='0.0.0.0', port=3838)"]
