FROM streamsets/datacollector:3.3.0-latest

ARG ADD_LIBS=streamsets-datacollector-elasticsearch_5-lib,streamsets-datacollector-jdbc-lib,streamsets-datacollector-jython_2_7-lib

RUN if [[ ! -z $ADD_LIBS ]]; then $SDC_DIST/bin/streamsets stagelibs -install=$ADD_LIBS ; fi

USER root
COPY docker-entrypoint.sh /
RUN ["chmod", "+x", "/docker-entrypoint.sh"]
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["dc", "-exec"]
