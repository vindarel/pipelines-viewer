
View the last Gitlab pipelines and their status.

Really not much here! Except it does the job \o/

```
$ pipelines-viewer
OK  2020-12-23T21:44:14.261Z
OK  2020-12-23T21:20:41.078Z
FAILED  2020-12-23T20:50:23.998Z
skipped  2020-12-23T20:21:29.997Z
OK  2020-12-23T20:20:23.708Z
skipped  2020-12-23T20:06:43.823Z
skipped  2020-12-23T19:37:06.454Z
OK  2020-12-23T17:57:24.995Z
skipped  2020-12-22T14:59:15.645Z
OK  2020-12-08T18:18:36.785Z
```

It reads the repository's group and name from the first remote in the
`.git/config`. When you use several remotes, the Gitlab one with the
issues and pipelines must be placed first. Room for
improvement. (Consider that need if this script was not limited to Gitlab)

Optional: accepts the username and project as arguments:

     $ pipelines-viewer vindarel abelujo

See also:

- https://github.com/profclems/glab
- https://github.com/nbedos/cistern (discontinued).