<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<html> 
	<head> 
		<title>桥牌计分</title> 
		<%=tour.head %>
	</head> 
	<body>
		<div data-role="page">
				<ol data-role="listview">
					<li> <a href="brg.lp">录入器</a></li>
					<li> <a href="score.lp">复式计算</a></li>
					<li> <a href="ximp_rs.lp">全场结果</a></li>
					<li> <a href="round.lp">通讯赛轮转表</a></li>
					<li> <a href="txs_rs.lp">通讯赛结果</a></li>
					<li> <a href="edit.lp">解锁比赛</a></li>
					<li> <a href="admin.lp">创建队式比赛</a></li>
					<li> <a href="txs.lp">创建通讯赛</a></li>
					<li> <a href="userlist.lp">人员列表</a></li>
				</ol>
			<%=tour.footer %>
		</div>
	</body>
</html>

