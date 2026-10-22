# organoR

`organoR` creates grade-ranked organisational organograms from tidy relationship data.

```r
library(organoR)
data <- read_org_data(system.file("extdata", "complex_org.csv", package = "organoR"))
validate_org_data(data)
render_all_teams(data, "organograms.html")
```
