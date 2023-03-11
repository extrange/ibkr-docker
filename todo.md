Features to write:

- check if other packages should be installed
- delete previous TWS images
- 2 stage build to save size
- add a browser
- workflow: whenever there are new versions, workflow should make a PR
    - Build dockerfiles on push with version tag starting with v
    - but push to new commit with v tag? Otherwise what will the publish.yml use?

Usage:

- Choose docker image - either latest or stable (both tws and gateway are in one)
- Set compose.yml variables: -all based on IBCAlpha defaults
    - GATEWAY_OR_TWS: gateway or tws (default)
    - TWOFA_TIMEOUT_ACTION: default: restart
    - USERNAME
    - PASSWORD
    - IBC_TradingMode: default live
    - IBC_*: override IBC configs with matching name
- API port will be 8888

Documentation:

- Gateway includes TWS

ports: https://www.interactivebrokers.com/en/?f=%2Fen%2Fgeneral%2Ftws-notes-954.php