  -- 1.List top 10 artists who created highest number of famous paintings? ---------------------------
SELECT full_name as top_10_artists, count(work_id) as count_of_paintings
FROM work w
LEFT JOIN artist a
ON w.artist_id = a.artist_id
GROUP BY full_name
ORDER BY count(work_id) DESC
LIMIT 10;

-- 2. What was the most commonly used style and subject by the top 10 artists? ------------------------------
SELECT DISTINCT(a.full_name) AS artist,
       (SELECT style FROM (SELECT style, COUNT(work_id) FROM work GROUP BY style ORDER BY COUNT(work_id) DESC LIMIT 1) AS tbl1) AS style,
       (SELECT subject FROM (SELECT subject, COUNT(work_id) FROM work GROUP BY subject ORDER BY COUNT(work_id) DESC LIMIT 1) AS tbl2) AS subject,
       COUNT(w.work_id) AS count_paintings
FROM artist a
JOIN work w ON a.artist_id = w.artist_id
JOIN subject s ON w.work_id = s.work_id
GROUP BY a.full_name, style, subject
ORDER BY count_paintings DESC
LIMIT 10; 

-- 3. What % of the artists' paintings were of their favourite subject? ---------------------------
SELECT a.full_name as artist, 
(SELECT subject FROM (SELECT subject, COUNT(w.work_id) FROM work GROUP BY subject ORDER BY COUNT(w.work_id) DESC LIMIT 1) AS tbl1) AS subject,
(count(w.work_id)/(SELECT count(w2.work_id) FROM work w2 WHERE w2.artist_id = w.artist_id)) as percentage
FROM artist a
JOIN work w ON a.artist_id = w.artist_id
JOIN subject s ON w.work_id = s.work_id
GROUP BY artist, subject
ORDER BY count(w.work_id) DESC
LIMIT 10; 

-- 4.What is the subject of most expensive painting(regular price)? -------------------------------
SELECT subject,regular_price_$k as price
FROM subject s
LEFT JOIN price_size p
ON s.work_id = p.work_id
WHERE regular_price_$k = (SELECT max(regular_price_$k) FROM price_size); 


-- 5. Which artist created the most expensive collection of paintings? ---------------------------------
SELECT a.artist_id, full_name as artist, SUM(regular_price_$k) as cost_of_collection
FROM artist a
JOIN work w ON (a.artist_id= w.artist_id)
JOIN price_size p ON (w.work_id = p.work_id)
GROUP BY full_name, a.artist_id
ORDER BY SUM(regular_price_$k)DESC
LIMIT 10;

-- 6. Which artist had the highest average cost of their paintings? --------------------------------------
SELECT a.artist_id, full_name as artist, avg(regular_price_$k) as avg_cost_of_paintings
FROM artist a
JOIN work w ON (a.artist_id= w.artist_id)
JOIN price_size p ON (w.work_id = p.work_id)
GROUP BY full_name, a.artist_id
ORDER BY avg(regular_price_$k)DESC
LIMIT 10;

-- 7. Which style of paintings is the most expensive? --------------------------------------
SELECT style, avg(regular_price_$k) as avg_price
FROM work w
JOIN price_size p ON (w.work_id = p.work_id)
GROUP BY style
ORDER BY avg(regular_price_$k) DESC
LIMIT 1;

-- 8. Is there a favoured style of paintings displayed by each museum? -----------------------------------
SELECT museum, style, Num_of_paintings
FROM (SELECT m.name as museum, style, count(w.work_id) as Num_of_paintings, 
			 ROW_NUMBER() OVER(Partition by m.name ORDER BY count(w.work_id)DESC) as row_num
             FROM work w
             LEFT JOIN museum m ON (w.museum_id = m.museum_id)
			 GROUP BY m.name, style) tbl1
             WHERE row_num <= 5 and num_of_paintings > 5; 
                          
		
-- 9.  Which museum has most number of Claude Monet paintings? ---------------------------------------
SELECT m.name as Museum, COUNT(work_id) as count_of_monet_paintings
FROM work w
LEFT JOIN museum m ON (m.museum_id = w.museum_id)
WHERE artist_id = (SELECT artist_id FROM artist WHERE full_name ="Claude Monet")
GROUP BY museum
ORDER BY count_of_monet_paintings DESC
LIMIT 1;		


-- 10. What time will 'The Metropolitan Museum of Art' open on February 5, 2024? 
SELECT day, open
FROM museum_hours 
WHERE day = dayname('2024-02-05')
AND museum_id = (SELECT museum_id FROM museum WHERE name = 'The Metropolitan Museum of Art')






