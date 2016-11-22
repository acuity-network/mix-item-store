.. _gas_usage:

#########
Gas usage
#########

The base price for creating a new blob is 45760 gas. It costs on average an additional 76.32 gas per byte that is stored in the blob. Additional revisions have slightly different base prices, depending on the revision number. Updating any existing revision has a base price of 32589.

+------------------+-------------+-------------+------------+----------------+
| Blockchain       | Gas price   | Unit price  | Blob   | Additional     |
|                  |             |             | base price | price per 1 kB |
+==================+=============+=============+============+================+
| Ethereum         | 21.557 gwei | $ 10.01     | $ 0.0099   | $ 0.0168       |
+------------------+-------------+-------------+------------+----------------+
| Ethereum Classic | 20 gwei     | $ 0.8516    | $ 0.0008   | $ 0.0013       |
+------------------+-------------+-------------+------------+----------------+
| Expanse          | 20 gwei     | $ 0.2293    | $ 0.0002   | $ 0.0004       |
+------------------+-------------+-------------+------------+----------------+
Gas and unit prices taken on 2016-11-22.

.. raw:: html

    <iframe width="700" height="455" src="//embed.chartblocks.com/1.0/?c=5833f8dc9973d2401022b179&t=6ad0758ea8b4f9c" frameBorder="0"></iframe>
