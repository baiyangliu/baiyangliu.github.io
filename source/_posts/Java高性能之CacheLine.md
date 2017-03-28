title: Java高性能之CacheLine
author: baiyangliu
tags:
- Java
- 高性能
categories:
- 编码
date: 2017-3-28 14:27:19
---

```
public class TestL1CacheMiss {
    private static final int RUNS = 10;
    private static final int DIMENSION_1 = 1024 * 1024 * 8;
    private static final int DIMENSION_2 = 6;

    private static long[][] longs;

    @Before
    public void init() {
        longs = new long[DIMENSION_1][];
        for (int i = 0; i < DIMENSION_1; i++) {
            longs[i] = new long[DIMENSION_2];
            for (int j = 0; j < DIMENSION_2; j++) {
                longs[i][j] = 0L;
            }
        }
    }

    @Test
    public void slow() {
        long sum = 0L;
        for (int r = 0; r < RUNS; r++) {
            final long start = System.nanoTime();
            for (int j = 0; j < DIMENSION_2; j++) {
                for (int i = 0; i < DIMENSION_1; i++) {
                    sum += longs[i][j];
                }
            }
            System.out.println((System.nanoTime() - start));
        }
    }

    @Test
    public void fast() {
        long sum = 0L;
        for (int r = 0; r < RUNS; r++) {
            final long start = System.nanoTime();
            for (int i = 0; i < DIMENSION_1; i++) {
                for (int j = 0; j < DIMENSION_2; j++) {
                    sum += longs[i][j];
                }
            }
            System.out.println((System.nanoTime() - start));
        }
    }
}
```
