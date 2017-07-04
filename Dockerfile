FROM streamsets/datacollector:2.6.0.1

ENV ADD_LIBS=streamsets-datacollector-elasticsearch_5-lib,streamsets-datacollector-jdbc-lib,streamsets-datacollector-jython_2_7-lib

USER root

RUN if [[ ! -z $ADD_LIBS ]]; then $SDC_DIST/bin/streamsets stagelibs -install=$ADD_LIBS ; fi && \
    mkdir -p ${STREAMSETS_LIBRARIES_EXTRA_DIR}/streamsets-datacollector-jdbc-lib/lib && \
    chown -R "${SDC_USER}:${SDC_USER}" "${STREAMSETS_LIBRARIES_EXTRA_DIR}" 

USER ${SDC_USER}
EXPOSE 18630
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["dc", "-exec"]
