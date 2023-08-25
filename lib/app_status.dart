enum Status {
  missingSource(description: "Selezionare una cartella di origine"),
  missingTarget(description: "Selezionare una certella di destinazione"),
  ready(description: "Pronto ad eseguire"),
  loading(description: "Caricamento"),
  finished(description: "Terminato");

  const Status({required this.description});

  final String description;
}