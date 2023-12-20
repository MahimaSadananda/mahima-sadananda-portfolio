# YouTube Data Analysis

This directory contains the notebook with code, dataset(s), and a PowerPoint file.


# Description

The project focuses on analyzing YouTube video data from Music Artist YouTubers, aiming to uncover the key elements behind a video's success on the platform. It also delves into exploring trending topics within this niche using Natural Language Processing (NLP).

# Technologies / Libraries Used:

1. Python
2. pandas
3. NumPy
4. Matplotlib
5. seaborn
6. Plotly
7. NLTK

# Data Dictionary

The “video_df” dataframe comprises 1446 rows and 12 columns.

| Variable | Description |
| --- | --- |
| video_id | unique identifier for each video |
| channelTitle | title of the YouTube channel associated with the video |
| title | title of the video |
| description |	textual description provided for the video |
| tags | keywords or labels associated with the video |
| publishedAt |	date and time when the video was published |
| viewCount |	number of views the video has received |
| likeCount |	number of likes the video has received |
| commentCount | number of comments posted on the video |
| duration | duration or length of the video |
| definition | video resolution or quality |
| caption | indicates whether captions are available for the video |

The “comments_df” dataframe has 1323 rows and 2 columns.

| Variable | Description |
| --- | --- |
| video_id | unique identifier for each video, linking it to the corresponding video in "video_df" |
| comments | textual content of comments posted on the associated video |
