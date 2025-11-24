/*
=============================================================================
    PROJECT:    RR 2026 IPL Auction Strategy
    FILE:       Auction_Data_Analysis.sql
    AUTHOR:     Luv Mutreja
    PURPOSE:    Extracts performance metrics for Bowlers and Batters to 
                identify retention gaps and auction targets.
    DB ENGINE:  MySQL
=============================================================================
*/

-- ==========================================================================
-- SECTION 1: DATA PREPARATION
-- Creating tables for Batters and Bowlers to standardize data types.
-- ==========================================================================

-- 1.1: Table for Bowlers
CREATE TABLE bowlers;
WITH t1 AS (
			SELECT match_id
				,player_id
				,player_name
				,cast(overs_bowled AS DECIMAL(5, 1)) overs
				,cast(runs_conceded AS signed) runs
				,cast(wicket_taken AS signed) wickets
				,cast(maiden_overs_bowled AS signed) maiden
				,cast(dot_balls_bowled AS signed) dot_balls
				,cast(economy_rate AS DECIMAL(5, 2)) economy
			FROM player_match_stats pms
			WHERE cast(overs_bowled AS DECIMAL(5, 1)) > 0
				AND match_date >= '2024-01-01'
			)

SELECT m.match_id
	,t1.player_id
	,pctm.team_name team
	,p.bowling_type
	,CASE 
		WHEN pctm.team_name = home_team
			THEN away_team
		ELSE home_team
		END against_team
	,match_format match_type
	,c.name league
	,m.stage
	,m.match_date
	,venue_name stadium
	,venue_country stadium_country
	,CASE 
		WHEN m.toss_win_team_id = pctm.team_id
			AND toss_opted = 'Fielding'
			THEN 1
		WHEN m.toss_win_team_id = pctm.team_id
			AND toss_opted = 'Batting'
			THEN 2
		WHEN toss_opted = 'Fielding'
			THEN 2
		WHEN toss_opted = 'Batting'
			THEN 1
		END innings
	,t1.player_name
	,overs
	,runs
	,wickets
	,maiden
	,dot_balls
	,economy
	,CASE 
		WHEN wickets > 0
			THEN runs / wickets
		ELSE NULL
		END average
	,CASE 
		WHEN wickets > 0
			THEN ((FLOOR(overs) * 6) + (overs % 1 * 10)) / wickets
		ELSE NULL
		END strike_rate
	,row_number() OVER (
		PARTITION BY m.match_id
		,t1.player_id
		) rn
FROM t1
JOIN matches m ON t1.match_id = m.match_id
JOIN player_competition_team_mapping pctm ON t1.player_id = pctm.player_id
	AND m.comp_id = pctm.comp_id
JOIN competitions c ON m.comp_id = c.comp_id
JOIN players p ON t1.player_id = p.player_id;

-- 1.2: Table for Batsmen
CREATE TABLE batsmen;
WITH t1 AS (
			SELECT match_id
				,match_date
				,player_id
				,player_name
				,cast(batting_order AS signed) in_at
				,CASE cast(Dismissal_Status AS signed)
					WHEN 2
						THEN 1
					ELSE 0
					END notout
				,cast(runs_scored AS signed) runs
				,cast(balls_faced AS signed) balls
				,cast(strike_rate AS DECIMAL(5, 2)) strike_rate
				,cast(no_of_sixes AS signed) 6s
				,cast(no_of_fours AS signed) 4s
				,cast(number_of_catches_taken AS signed) catches
				,cast(number_of_stumping AS signed) stumpings
			FROM player_match_stats pms
			WHERE cast(balls_faced AS signed) > 0
				AND match_date >= '2024-01-01'
			ORDER BY match_date DESC
			)

SELECT m.match_id
	,t1.player_id
	,pctm.team_name team
	,CASE 
		WHEN pctm.team_name = home_team
			THEN away_team
		ELSE home_team
		END against_team
	,match_format match_type
	,c.name league
	,m.stage
	,m.match_date
	,venue_name stadium
	,venue_country stadium_country
	,CASE 
		WHEN m.toss_win_team_id = pctm.team_id
			AND toss_opted = 'Fielding'
			THEN 2
		WHEN m.toss_win_team_id = pctm.team_id
			AND toss_opted = 'Batting'
			THEN 1
		WHEN toss_opted = 'Fielding'
			THEN 1
		WHEN toss_opted = 'Batting'
			THEN 2
		END innings
	,t1.player_name
	,in_at
	,notout
	,runs
	,balls
	,strike_rate
	,6s
	,4s
	,catches
	,stumpings
	,row_number() OVER (
		PARTITION BY m.match_id
		,t1.player_id
		) rn
FROM t1
JOIN matches m ON t1.match_id = m.match_id
JOIN player_competition_team_mapping pctm ON t1.player_id = pctm.player_id
	AND m.comp_id = pctm.comp_id
JOIN competitions c ON m.comp_id = c.comp_id;

-- ==========================================================================
-- SECTION 2: DATA CLEANING
-- Fixing missing flags for Wicket Keepers
-- ==========================================================================

WITH t1
AS (
	SELECT DISTINCT player_id
		,player_name
		,number_of_stumping
	FROM player_match_stats
	WHERE number_of_stumping > 0
	)
UPDATE players a
JOIN t1 ON a.player_id = t1.player_id
SET is_wicket_keeper = 1;

-- =============================================================================================
-- SECTION 3: TABLE WISE CODE
-- I have pasted table's SS in the Auction_Strategy.pdf the code for those table is as follows
-- =============================================================================================

-- 3.1: Code for Table1 (Bowler and Spinner Type)
SELECT DISTINCT player_name
	,bowling_type
FROM bowlers
WHERE player_name IN (
		'Ravindra Jadeja'
		,'Riyan Parag'
		,'Donovan Ferreira'
		)
ORDER BY CASE player_name
		WHEN 'Ravindra Jadeja'
			THEN 1
		WHEN 'Riyan Parag'
			THEN 3
		ELSE 2
		END;
        
-- 3.2: Code for Table2 (Right Arm Leggies)
SELECT a.player_name
	,sum(overs) overs
	,sum(wickets) wickets_taken
	,sum(runs) runs_conceeded
	,sum(dot_balls) dots_bowled
	,round(((sum(FLOOR(overs)) * 6) + sum((overs % 1 * 10))) / sum(wickets), 2) strikerate
	,round(sum(CASE 
				WHEN wickets = 0
					THEN runs
				END) / sum(CASE 
				WHEN wickets = 0
					THEN overs
				END), 2) econ_0wick_games
	,sum(CASE 
			WHEN wickets > 1
				THEN 1
			ELSE 0
			END) / count(match_id) multiwicket_percentage
	,sum(dot_balls) / ((sum(FLOOR(overs)) * 6) + sum((overs % 1 * 10))) dot_ball_percentage
	,sum(dot_balls) / sum(wickets) dot_to_wicket
FROM bowlers a
JOIN player_list b ON a.player_name = b.player_name
WHERE bowling_type = 'Right-arm Leg-Break'
	AND match_date >= '2025-01-01'
GROUP BY a.player_name
HAVING sum(overs) >= 20;

-- 3.3: Code for Table4 (Auction Details for Shortlisted Leggies)
SELECT name
	,pl.base_price base_price2026
	,category
	,au.base_price base_price2025
	,au.final_price final_price2025
	,sold_to sold_to2025
FROM auction_summary au
JOIN player_list pl ON au.name = pl.player_name
WHERE au.year = 2025
	AND au.name IN (
		'Adam Zampa'
		,'Mohammad Rishad Hossain'
		,'KC Cariappa'
		,'Prashant Solanki'
		);

-- 3.4: Code for Table5 (Indian WK Batters)
SELECT DISTINCT a.player_name
	,left(batting_type, 1) Handed
	,count(DISTINCT match_id) matches
	,sum(runs) Runs
	,sum(balls) Balls
	,sum(runs) / sum(balls) * 100 SR
	,sum(CASE 
			WHEN runs >= 30
				THEN runs
			ELSE 0
			END) / sum(CASE 
			WHEN runs >= 30
				THEN balls
			ELSE 0
			END) * 100 SR_gt30runs
	,(sum(4s) + sum(6s)) / sum(balls) boundary_percentage
	,sum(CASE 
			WHEN runs >= 30
				AND runs / balls * 100 > 150.00
				THEN 1
			ELSE 0
			END) / count(DISTINCT match_id) impact_innings_percentage
	,(sum(runs) - (sum(4s) * 4) - (sum(6s) * 6)) / (sum(balls) - sum(4s) - sum(6s)) * 100 non_boundary_sr
FROM players a
JOIN player_list b ON a.player_name = b.player_name
JOIN batsmen c ON a.player_id = c.player_id
WHERE category = 'Indian'
	AND is_wicket_keeper = 1
	AND match_date >= '2025-01-01'
GROUP BY 1
	,2
HAVING count(DISTINCT match_id) >= 5;

-- 3.5: Code for Table7 (Auction Details for Shortlisted Indian WK)
SELECT name
	,pl.base_price base_price2026
	,category
	,au.base_price base_price2025
	,au.final_price final_price2025
	,sold_to sold_to2025
FROM auction_summary au
JOIN player_list pl ON au.name = pl.player_name
WHERE au.year = 2025
	AND au.name IN (
		'Tushar Raheja'
		,'Tejasvi Dahiya'
		,'Salil Arora'
		);

-- 3.6: Code for Table8 (Pretorius Batting Stats)
SELECT CASE 
		WHEN match_type = 'T20I'
			THEN 'international'
		ELSE league
		END match_type
	,round(sum(runs) / sum(balls) * 100, 2) strikerate
	,sum(runs) / sum(CASE 
			WHEN notout = 0
				THEN 1
			ELSE 0
			END) average
	,round((sum(4s) + sum(6s)) / sum(balls) * 100, 2) boundary_percentage
	,sum(CASE 
			WHEN strike_rate < 120
				AND balls > 5
				THEN 1
			ELSE 0
			END) slow_innings
	,(sum(runs) - (sum(4s) * 4) - (sum(6s) * 6)) / (sum(balls) - sum(4s) - sum(6s)) * 100 non_b_sr
	,sum(CASE 
			WHEN runs >= 25
				AND strike_rate >= 150
				THEN 1
			ELSE 0
			END) high_impact_innings
	,round(sum(sum(runs)) OVER() / sum(sum(balls)) OVER() * 100, 2) strikerate_overall
	,sum(sum(runs)) OVER() / sum(sum(CASE 
				WHEN notout = 0
					THEN 1
				ELSE 0
				END)) OVER() average_overall
	,round((sum(sum(4s)) OVER() + sum(sum(6s)) OVER()) / sum(sum(balls)) OVER() * 100, 2) boundary_percentage_overall
	,sum(sum(CASE 
				WHEN strike_rate < 120
					AND balls > 5
					THEN 1
				ELSE 0
				END)) OVER() slow_innings_overall
	,(sum(sum(runs)) OVER() - (sum(sum(4s)) OVER() * 4) - (sum(sum(6s)) OVER() * 6)) / (sum(sum(balls)) OVER() - sum(sum(4s)) OVER() - sum(sum(6s)) OVER()) * 100 non_b_sr_overall
	,sum(sum(CASE 
				WHEN runs >= 25
					AND strike_rate >= 150
					THEN 1
				ELSE 0
				END)) OVER() high_impact_innings_overall
FROM batsmen
WHERE player_name = 'Lhuan Pretorius'
	AND in_at IN (
		1
		,2
		,3
		)
GROUP BY CASE 
		WHEN match_type = 'T20I'
			THEN 'international'
		ELSE league
		END;

-- 3.7: Code for Table9 (Overseas Top Order RHB)
SELECT a.player_name
	,sum(runs) / count(CASE 
			WHEN notout = 0
				THEN match_id
			ELSE NULL
			END) avg1
	,count(DISTINCT match_id) matches
	,sum(runs) Runs
	,sum(balls) Balls
	,sum(runs) / sum(balls) * 100 SR
	,(sum(4s) + sum(6s)) / sum(balls) boundary_percentage
	,sum(CASE 
			WHEN runs >= 30
				AND runs / balls * 100 > 150.00
				THEN 1
			ELSE 0
			END) / count(DISTINCT match_id) impact_innings_percentage
	,(sum(runs) - (sum(4s) * 4) - (sum(6s) * 6)) / (sum(balls) - sum(4s) - sum(6s)) * 100 non_boundary_sr
FROM players a
JOIN player_list b ON a.player_name = b.player_name
JOIN batsmen c ON a.player_id = c.player_id
WHERE (
		match_type = 'T20I'
		OR league LIKE 'IPL%'
		)
	AND match_date >= '2024-01-01'
	AND left(batting_type, 1) = 'R'
	AND in_at IN (
		1
		,2
		,3
		,4
		)
GROUP BY 1
HAVING matches > 10
	AND sr > 150
	AND avg1 > 30;

-- 3.8: Code for Table11 (Auction Details for Shortlisted Overseas Top Order RHB)
SELECT name
	,pl.base_price base_price2026
	,category
	,au.base_price base_price2025
	,au.final_price final_price2025
	,sold_to sold_to2025
FROM auction_summary au
JOIN player_list pl ON au.name = pl.player_name
WHERE au.year = 2025
	AND au.name IN (
		'Daryl Joseph Mitchell'
		,'Shai Hope'
		);

-- ======
-- NOTES
-- ======

-- Team Composition and probable playing 11 are made using Canva.
-- Other tables and formatting are handled in Excel.

