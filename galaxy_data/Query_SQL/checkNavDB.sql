select a.[Dimension Code],	a.Code,	a.Name, a.[Blocked], b.[Table ID],	b.[No_],	b.[Dimension Code],	b.[Dimension Value Code] 
from [GALAXY_DIS$Dimension Value] a 
left join [GALAXY_DIS$Default Dimension] b on concat(a.[Dimension Code],	a.Code) = concat(b.[Dimension Code], b.[Dimension Value Code])
where a.[Code] = 'VASCF01'

