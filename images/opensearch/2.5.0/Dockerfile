FROM opensearchproject/opensearch:2.5.0

RUN /usr/share/opensearch/bin/opensearch-plugin remove opensearch-security
RUN /usr/share/opensearch/bin/opensearch-plugin install --batch analysis-icu analysis-phonetic

EXPOSE 9200 9300