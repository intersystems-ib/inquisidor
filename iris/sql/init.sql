USE DATABASE "INQUISIDOR"
GO
CREATE FOREIGN SERVER Inquisidor.CPVDir FOREIGN DATA WRAPPER CSV HOST '/iris-shared/cpv'
GO
CREATE FOREIGN TABLE Inquisidor_Object.CPV (
   code VARCHAR(15), 
   description VARCHAR(500)
) SERVER Inquisidor.CPVDir FILE 'codes.csv'
GO
CREATE INDEX HNSWIndex ON TABLE Inquisidor_Object.Licitacion (TituloVectorizado)
  AS HNSW(Distance='DotProduct')
GO
CREATE INDEX HNSWIndex ON TABLE Inquisidor_Object.LicitacionTemp (TituloVectorizado)
  AS HNSW(Distance='DotProduct')
GO