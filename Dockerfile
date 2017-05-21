FROM docker:stable
COPY ./src /app
CMD ["/app/update.sh"]