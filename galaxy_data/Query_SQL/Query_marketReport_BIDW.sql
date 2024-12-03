-- update marketreport

set screen_format = case when lower(cinema_format) like '%screen x%' then 'SCREEN X'
	when lower(cinema_format) like '%starium%' then 'STARIUM'
	when lower(cinema_format) like '%4dx%' then '4DX'
	when lower(cinema_format) like '%imax%' then 'IMAX'
	else 'NORMAL' end


set distributor_filter = case when lower(distributor) = 'bhd' then 'BHD'
	when lower(distributor) = 'cgv' then 'CGV'
	when lower(distributor) = 'glx' then 'GALAXY'
	when lower(distributor) = 'lotte' then 'LOTTE'
	when lower(distributor) = 'sg media' then 'SG MEDIA'
	when lower(distributor) in ('beta','beta media') then 'BETA'
	else 'OTHERS' end

set group_studio_filter = case when group_studio = 'Celestial Tigers' then 	'Independent'
when group_studio = 'Disney' then	'Walt Disney'
when group_studio = 'Fox'	then 	'20th Century Fox'
when group_studio = 'Inde'	then 	'Independent'
when group_studio = 'Independent'	then 	'Independent'
when group_studio = 'Local'	then 	'Local'
when group_studio = 'Paramount'	then 	'Paramount'
when group_studio = 'Sony'	then 	'Sony'
when group_studio = 'UIP'	then 	'Universal'
when group_studio = 'uni'	then 	'Universal'
when group_studio = 'Universal'	then 	'Universal'
when group_studio = 'Walt Disney'	then 	'Walt Disney'
when group_studio = 'warner'	then 	'Warner Bros'
when group_studio = 'Warner Bros'	then 	'Warner Bros'
when group_studio = 'WB'	then 	'Warner Bros'
else '' end


set group_studio_short =
	case when group_studio_filter = 'Independent' then 'Independent'
		when group_studio_filter = 'Local' then 'Local'
		when group_studio_filter = 'Paramount' then 'Para'
		when group_studio_filter = 'Sony' then 'Sony'
		when group_studio_filter = 'Universal' then 'UIP'
		when group_studio_filter = 'Walt Disney' then 'Disney'
		when group_studio_filter = 'Warner Bros' then 'WB'
		else group_studio_short end