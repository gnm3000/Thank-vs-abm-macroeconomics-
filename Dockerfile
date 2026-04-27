FROM gnm3000/r-shiny-finance:latest
#FROM rocker/r-ver:4.3.3

#RUN apt-get update && apt-get install -y --no-install-recommends \
#    libcurl4-openssl-dev \
#    libssl-dev \
#    libxml2-dev \
#    libfontconfig1-dev \
#    libfreetype6-dev \
#    libpng-dev \
#    libtiff5-dev \
#    libjpeg-dev \
#    libuv1-dev \
#    && rm -rf /var/lib/apt/lists/*

#RUN R -e "packages <- c('shiny','bslib','plotly','viridis','igraph','dplyr','tidyr','purrr','yaml'); installed <- rownames(installed.packages()); missing <- setdiff(packages, installed); if (length(missing) > 0) install.packages(missing, repos='https://cloud.r-project.org') else message('All requested packages are already installed.')"
#RUN R -e "library(shiny); packageVersion('shiny')"

WORKDIR /app
COPY app ./app

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/app/app', host='0.0.0.0', port=3838)"]
