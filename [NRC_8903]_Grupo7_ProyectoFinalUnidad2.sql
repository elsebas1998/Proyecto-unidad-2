--Utilizando la base de datos llamada Chinook usted debe crear al menos 10 consultas SQL que permitan proveer de información
--valiosa al usuario final. Las consultas deben considerar al menos 7 tablas. Además, usted debe considerar todos las 
--clausulas de SQL y las funciones de agregación vistas en clase (mire el material publicado en el aula virtual)

--Proporcione una consulta que muestre al cliente "Leonie Koler", con el agente por el que fue atendido y las pistas que le mostro con la descripcion de la misma completa
SELECT c.FirstName || " " || c.LastName AS "Cliente", e.FirstName || " " || e.LastName AS "Vendedor", t.Name AS "Cancion", a.Title AS "Album", ar.Name AS "Artista", g.Name  AS "Genero", tracks.UnitPrice AS "PrecioUnidad"
FROM customers c, employees e
INNER JOIN invoices i on i.CustomerId = c.customerId 
INNER JOIN invoice_items it on it.InvoiceId = i.InvoiceId 
INNER JOIN  tracks t on t.trackId = it.trackId
INNER JOIN albums a on a.AlbumId = t.AlbumId
INNER JOIN artists ar on ar.ArtistId = a.AlbumId
INNER JOIN genres g on g.GenreId = t.TrackId
INNER JOIN tracks on tracks.UnitPrice = it.UnitPrice
WHERE Cliente = "Leonie Köhler";

---------------------------------------------------------------------------
--Consulta para devolver el correo electrónico, el nombre, el apellido y el género de todos los oyentes de música rock, el ritulo del album y el tipo de medio.
--Devuelva su lista ordenada alfabéticamente por dirección de correo electrónico comenzando con A. Para no obtener duplicados 
--se vincula la información de las tablas customers, invoices, invoice_item, tracks y genre, albums y media_types.

SELECT DISTINCT C.Email, C.FirstName ||" "|| C.LastName AS "Nombre", G.Name, A.Title, MT.Name AS "Tipo de Medio"
FROM customers C
INNER JOIN invoices I ON C.CustomerId = I.CustomerId
INNER JOIN invoice_items IL ON I.InvoiceId = IL.InvoiceId
INNER JOIN tracks T ON IL.TrackId = T.TrackId 
INNER JOIN genres G ON T.GenreId = G.GenreId
INNER JOIN albums A ON T.AlbumId = A.AlbumId 
INNER JOIN media_types MT ON T.MediaTypeId = MT.MediaTypeId
WHERE G.Name = "Rock"
ORDER BY C.Email;

-------------------------------------------------------------------------------------------------------
-- Determinamos el género más popular como el género con la mayor cantidad de compras.
-- Escriba una consulta que devuelva cada país junto con el Género principal. 
-- Para países donde se comparte el número máximo de compras devolver todos los Géneros.
-- Para esta consulta, deberá utilizar las tablas Invoice, InvoiceLine, Customer, Track y Genre.
--Se usa la clausula With para definir mas expresiones.
WITH x AS (
SELECT COUNT(i.InvoiceId) Purchases, c.Country, g.GenreId, g.Name, pt.TrackId, pl.Name AS "ListaResproduccion"
FROM invoices i
INNER JOIN customers c ON i.CustomerId = c.CustomerId
INNER JOIN invoice_items il ON il.Invoiceid = i.InvoiceId
INNER JOIN tracks t ON t.TrackId = il.Trackid
INNER JOIN genres g ON t.GenreId = g.GenreId
INNER JOIN playlist_track pt ON t.TrackId = pt.TrackId 
INNER JOIN playlists pl on pt.PlaylistId = pl.PlaylistId
GROUP BY c.Country, g.Name
ORDER BY c.Country, Purchases DESC
)
SELECT x.*
FROM x
JOIN (
SELECT MAX(Purchases) AS MaxPurchases, Country, Name, GenreId
FROM x
GROUP BY Country
)y
ON x.Country = y.Country
WHERE x.Purchases = y.MaxPurchases;

-----------------------------------------------------------------------------------------------------
--Consulta donde se observen los 10 clientes con el importe total de las facturas con mayor valor. 
SELECT a.Name, round(SUM(il.Quantity * il.UnitPrice),2) AS MontoGastado, c.CustomerId, c.FirstName ||" "|| c.LastName AS "Cliente", g.Name AS "Genero"
FROM artists a
INNER JOIN albums al ON a.ArtistId = al.ArtistId
INNER JOIN tracks t ON t.AlbumId = al.AlbumId
INNER JOIN invoice_items il ON t.TrackId = il.Trackid
INNER JOIN invoices i ON il.InvoiceId = i.InvoiceId
INNER JOIN customers c ON c.CustomerId = i.CustomerId
INNER JOIN genres g on t.GenreId = g.GenreId
GROUP BY c.CustomerId
ORDER BY MontoGastado DESC
LIMIT 10;

----------------------------------------------------------------------------------------------------
--consulta de las ventas anuales totales en tres países seleccionados.
SELECT CAST(strftime('%Y', invoices.InvoiceDate) AS BIGINT) AS "Year",
   SUM(CASE WHEN invoices."BillingCountry" = 'USA'
      THEN round(invoices.Total,2) END) AS "USA",
   SUM(CASE WHEN invoices.BillingCountry = 'United Kingdom'
      THEN round(invoices.Total,2) END) AS "United Kingdom",
   SUM(CASE WHEN invoices.BillingCountry = 'Canada'
      THEN round(invoices.Total,2) END) AS "Canada"
FROM Invoices AS invoices
WHERE BillingCountry IN ('USA', 'United Kingdom', 'Canada')
GROUP BY 1
ORDER BY 1 DESC;

--------------------------------------------------------------------------------------
-- Consulta que muestre de forma detallada una pista, la cual muestra el compositos, la duracion tiempo, precio por unidad
--tipo de medio el nombre de la lista musical, genero, cantidad, fecha de creacion y total
select t.Name as Trace_name, t.Composer as Composer, t.Milliseconds as duration_in_ms, t.UnitPrice,
       m.Name as media_type, p.Name as playlist_name, ab.Title as title, art.Name as artist_name,
       g.Name as genre, vl.Quantity, v.InvoiceDate,v.Total
from tracks as t
left join media_types as mt on mt.MediaTypeId = t.MediaTypeId
left join media_types as m on t.MediaTypeId = m.MediaTypeId
left join playlist_track as pt on pt.TrackId = t.TrackId
left join playlists as p on p.PlaylistId = pt.PlaylistId
left join albums as ab on ab.AlbumId = t.AlbumId 
left join artists as art on art.ArtistId = ab.ArtistId
left join genres as g on g.GenreId = t.GenreId
left join invoice_items as vl on vl.TrackId = t.TrackId
left join invoices as v on v.InvoiceId = vl.InvoiceId
left join customers as c on c.CustomerId = v.CustomerId
left join employees as em on em.EmployeeId = c.SupportRepId
order by Trace_name;

-------------------------------------------------------------------------------------------
--Proporcionar una consulta donde se muestre total monto  que tenga cada una de las generos vendidos
SELECT p.PlaylistId, ar.Name AS "Artista", p.Name AS "Album", g.Name AS "Genero", round(sum(t.UnitPrice),2) AS "Total"
FROM invoices i
INNER JOIN invoice_items it on it.InvoiceId = i.InvoiceId
INNER JOIN tracks t ON t.TrackId = it.TrackId
INNER JOIN albums a ON a.AlbumId = t.AlbumId
INNER JOIN genres g ON t.GenreId = g.GenreId
INNER JOIN artists ar ON ar.ArtistId = a.ArtistId
INNER JOIN playlist_track pt ON t.TrackId = pt.TrackId 
INNER JOIN playlists p ON pt.PlaylistId = p.PlaylistId
GROUP BY Genero
ORDER BY Total DESC;

-------------------------------------------------------------------------------------------------

--Proporcione una consulta que muestre a todos los clientes que hayan comprado una pista especifica

SELECT customers.FirstName ||" "|| customers.LastName AS "Nombres", customers.Country, tracks.Name, playlists.PlaylistId, playlists.Name AS "Tipo"
FROM customers 
INNER JOIN invoices ON invoices.CustomerId = customers.CustomerId
INNER JOIN invoice_items ON invoice_items.InvoiceId = invoices.InvoiceId
INNER JOIN tracks ON tracks.TrackId = invoice_items.TrackId
INNER JOIN media_types ON media_types.MediaTypeId = tracks.MediaTypeId
INNER JOIN playlist_track ON playlist_track.TrackId = tracks.TrackId
INNER JOIN playlists ON playlists.PlaylistId = playlist_track.PlaylistId
WHERE tracks.Name = "For Those About To Rock (We Salute You)";
----------------------------------------------------------------------------------------------------------

--Se proporciona una consulta donde se muestra el artista, album y genero de la pista que se reproduce de forma mas frecuente en todas las ciudades
SELECT genres.GenreId ,artists.Name ,albums.Title, tracks.Name AS "Pista", genres.Name AS "Genero" ,customers.City
FROM customers 
INNER JOIN invoices ON customers.CustomerId = invoices.CustomerId
INNER JOIN invoice_items ON invoices.InvoiceId=invoice_items.InvoiceId
INNER JOIN tracks ON invoice_items.TrackId=tracks.TrackId
INNER JOIN albums ON tracks.AlbumId = albums.AlbumId
INNER JOIN genres ON genres.GenreId = tracks.GenreId
INNER JOIN artists ON albums.ArtistId = artists.ArtistId
GROUP By genres.Name 
ORDER By genres.GenreId  ASC;

--------------------------------------------------------------------------------------------------------

--Proporcione los top 5 artistas con mejores ganancias segun las facturas y dar uso a estos para encontrar el cliente que gasto mas en cada album de los artistass
WITH ArtistamasVendido AS
(
SELECT round(sum(il.UnitPrice * il.Quantity),2) as 'ArtistTotal', a.Name as 'ArtistName', a.ArtistId
FROM invoice_items il, tracks trk, albums alb, artists a
WHERE il.TrackId=trk.TrackId and
alb.AlbumId=trk.AlbumId and
a.ArtistId=alb.ArtistId
GROUP BY a.ArtistId
ORDER BY ArtistTotal DESC
LIMIT 5
)

SELECT 	bsa.ArtistName,
bsa.ArtistTotal, c.CustomerId    AS 'CustomerId', c.FirstName || ' ' || c.LastName AS 'CustomerName', al.Title , round(SUM(il.Quantity*il.UnitPrice),2) AS 'CustomerTotal'
FROM artists a 
INNER JOIN albums alb ON a.ArtistId = alb.ArtistId 
INNER JOIN tracks trk ON trk.AlbumId = alb.AlbumId 
INNER JOIN invoice_items il ON trk.TrackId = il.Trackid 
INNER JOIN invoices i ON il.InvoiceId = i.InvoiceId 
INNER JOIN customers c ON c.CustomerId = i.CustomerId 
INNER JOIN albums al ON trk.AlbumId = al.AlbumId
INNER JOIN ArtistamasVendido bsa ON bsa.ArtistId = a.ArtistId
GROUP BY c.CustomerId 
ORDER BY CustomerTotal DESC
LIMIT 5;

---------------------------------------------------------------------------------------------------
--Proporcione una consulta que muestre el nombre de los artistas y genero, con un monto generado por factura superior a las $80.
SELECT st.ArtistId, st.Name AS "NombreArtista", g.Name, i.BillingCity , i.InvoiceDate,round(SUM(il.Quantity)*il.UnitPrice,2) AS "Monto"
FROM artists st
INNER JOIN albums a ON st.ArtistId=a.ArtistId
INNER JOIN tracks t ON a.AlbumId=t.AlbumId
INNER JOIN invoice_items il ON il.TrackId=t.TrackId
INNER JOIN invoices i ON i.InvoiceId=il.InvoiceId
INNER JOIN customers c ON c.CustomerId=i.CustomerId
INNER JOIN genres g ON t.GenreId = g.GenreId
GROUP BY 2
HAVING Monto >80
ORDER BY SUM(il.Quantity)*il.UnitPrice DESC;

--------------------------------------------------------------------------------------------------------
