title: You can't specify target table 'department_user' for update in FROM clause
author: baiyangliu
tags:
- MySQL
categories:
- 编码
date: 2016-12-22 17:51:00
updated: 2017-01-05 17:54:08
description: You can't specify target table 'department_user' for update in FROM clause
---
![JSON](/imgs/fatalbug.png)
<!--more-->
###### 出现原因
MySQL中对同一张表Select的结果进行更新（删除）操作。
###### 应用场景
删除部门，要求将部门用户移动到父部门。
###### 问题分析
由于用户可能同时存在于本部门和父部门，因此在进行更新之前，需要将此类用户查出来直接删掉，然后更新部门ID。
###### 出错SQL
```sql
DELETE
FROM
	department_user
WHERE
	department_id = ?
AND user_id IN (
	SELECT
		user_id
	FROM
		department_user
	WHERE
		department_id = ?
	AND user_id IN (
		SELECT
			user_id
		FROM
			department_user
		WHERE
			department_id = ?
	)
)
```
###### 解决办法
将Select的中间结果再次Select。。。
###### 正确SQL
```sql
DELETE
FROM
	department_user
WHERE
	department_id = ?
AND user_id IN (
	SELECT
		t.user_id
	FROM
		(
			SELECT
				user_id
			FROM
				department_user
			WHERE
				department_id = ?
			AND user_id IN (
				SELECT
					user_id
				FROM
					department_user
				WHERE
					department_id = ?
			)
		) t
)
```