dataset keys | while read KY; do
    dataset read "$KY" > record.json
    URL=$(jsonmunge -i record.json -E '{{- with .doi -}}https://metrics-api.dimensions.ai/doi/{{- . -}}{{- end -}}')

    curl "$URL" > dimensions.json
    jsonmunge -i dimensions.json -E '{{- with .times_cited }}{"times_cited":{{- . -}}}{{- end -}}' > times_cited.json
    dataset -i times_cited.json join update "$KY"

    dataset -pretty read "$KY"
done


