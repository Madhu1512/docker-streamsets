FROM streamsets/datacollector:2.6.0.1

ARG ADD_LIBS=streamsets-datacollector-elasticsearch_5-lib,streamsets-datacollector-jdbc-lib,streamsets-datacollector-jython_2_7-lib

RUN if [[ ! -z $ADD_LIBS ]]; then $SDC_DIST/bin/streamsets stagelibs -install=$ADD_LIBS ; fi
