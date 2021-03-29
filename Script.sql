SELECT cbd.*,
	CASE WHEN DAYOFWEEK(cbd.`date`) IN (1,7) THEN 1 ELSE 0 END AS 'vikend',
	CASE WHEN MONTH(cbd.`date`) >= 3 AND MONTH(cbd.`date`) <= 5 THEN 0
		WHEN MONTH(cbd.`date`) >= 6 AND MONTH(cbd.`date`) <= 8 THEN 1
		WHEN MONTH(cbd.`date`) >= 9 AND MONTH(cbd.`date`) <= 11 THEN 2
		WHEN MONTH(cbd.`date`) = 12 OR MONTH(cbd.`date`) <= 2 THEN 3 END AS 'rocni_obdobi',
	c.population_density AS 'hustota obavatel',
	(SELECT e.GDP / e.population FROM economies e WHERE e.country = cbd.country AND e.`year` = YEAR(cbd.`date`)) AS 'HDP na obyvatele',
	(SELECT e.`gini` FROM economies e WHERE e.country = cbd.country AND e.`year` = YEAR(cbd.`date`)) AS 'GINI',
	(SELECT e.mortaliy_under5 FROM economies e WHERE e.country = cbd.country AND e.`year` = YEAR(cbd.`date`)) AS 'detska_umrtnost',
	c.median_age_2018 AS 'median veku v roce 2018',
	((SELECT r.population FROM religions r WHERE religion = 'Christianity' AND r.country = cbd.country AND r.`year` = 2010) / c.population) AS 'podil krestanstvi',
	((SELECT r.population FROM religions r WHERE religion = 'Islam' AND r.country = cbd.country AND r.`year` = 2010) / c.population) AS 'podil islam',
	((SELECT r.population FROM religions r WHERE religion = 'Hinduism' AND r.country = cbd.country AND r.`year` = 2010) / c.population) AS 'podil hinduismus',
	((SELECT r.population FROM religions r WHERE religion = 'Buddhism' AND r.country = cbd.country AND r.`year` = 2010) / c.population) AS 'podil budhismus',
	((SELECT r.population FROM religions r WHERE religion = 'Judaism' AND r.country = cbd.country AND r.`year` = 2010) / c.population) AS 'podil judaismus',
	((SELECT r.population FROM religions r WHERE religion = 'Folk Religions' AND r.country = cbd.country AND r.`year` = 2010) / c.population) AS 'podil lidova nabozenstvi',
	((SELECT r.population FROM religions r WHERE religion = 'Other Religions' AND r.country = cbd.country AND r.`year` = 2010) / c.population) AS 'podil ostatni nabozenstvi',
	((SELECT r.population FROM religions r WHERE religion = 'Unaffiliated Religions' AND r.country = cbd.country AND r.`year` = 2010) / c.population) AS 'podil nepridruzena nabozenstvi',
	((SELECT le.life_expectancy FROM life_expectancy le WHERE le.country = cbd.country AND le.`year` = '2015') -
	(SELECT le.life_expectancy FROM life_expectancy le WHERE le.country = cbd.country AND le.`year` = '1965')) AS 'rozdil doba doziti 1965/2015',
	(((SELECT SUM(w.temp) FROM weather w WHERE w.`hour` IN (6,15,21) AND w.`date` = cbd.`date` AND w.city = c.capital_city) + 
	(SELECT w.temp FROM weather w WHERE w.`hour` IN (21) AND w.`date` = cbd.`date` AND w.city = c.capital_city)) / 4) AS 'prumerna denni teplota',
	(SELECT COUNT(w.`hour`) FROM weather w WHERE w.rain <> 0 AND w.`date` = cbd.`date` AND w.city = c.capital_city) AS 'pocet hodin s nenulovymi srazkami',
	(SELECT MAX(w.gust) FROM weather w WHERE w.`date` = cbd.`date` AND w.city = c.capital_city) AS 'maximalni sila vetru v narazech'
FROM covid19_basic_differences cbd
INNER JOIN countries c ON c.country = cbd.country;