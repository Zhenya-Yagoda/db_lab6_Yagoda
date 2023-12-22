-- drop table score;
-- drop table movie;
-- drop table director;
-- drop table star;
-- drop table writer;

-- select * from director;
-- select * from movie;
-- select * from score;
-- select * from star;
-- select * from writer;

DROP FUNCTION IF EXISTS get_movie_count_writer();

-- 1. кількість фільмів в кожного сценариста
CREATE OR REPLACE FUNCTION get_movie_count_writer() RETURNS TABLE(writer_name varchar(50), movie_count bigint)
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
		SELECT writer.name_w AS writer_name, COUNT(movie.id_movie) AS movie_count
		FROM writer 
		JOIN movie ON writer.id_writer = movie.id_writer
		GROUP BY writer.id_writer, writer.name_w;
END;
$$;

SELECT * FROM get_movie_count_writer();

