# Navigate to the DiskSpd folder
CD E:\LabFiles\M02L02Lab01\DiskSpd-2.0.21a\amd64

# Execute the following tests and analyze the results.

## Review disk performance for random IO operations (OLTP)
.\diskspd.exe -c10G -d20 -r -w80 -t8 -o8 -b8K -Sh -L F:\testfile.dat

## Review disk performance for sequential IO operations (Table Scan)
.\diskspd.exe -c10G -d20 -si -w0 -t8 -o8 -b512K -Sh -L F:\testfile.dat

## Review disk performance for sequential IO operations (TransactionLog)
.\diskspd.exe -c10G -d20 -si -w100 -t8 -o8 -b60K -Sh -L F:\testfile.dat


# =========================
# Exeute the different workloads and monitor with perfmon
# =========================

## Review disk performance for random IO operations (OLTP)
.\diskspd.exe -c10G -d20 -r -w80 -t8 -o8 -b8K -Sh -L F:\testfile.dat

Start-Sleep -Seconds 20

## Review disk performance for sequential IO operations (Table Scan)
.\diskspd.exe -c10G -d20 -si -w0 -t8 -o8 -b512K -Sh -L F:\testfile.dat

Start-Sleep -Seconds 20

## Review disk performance for sequential IO operations (TransactionLog)
.\diskspd.exe -c10G -d20 -si -w100 -t8 -o8 -b60K -Sh -L F:\testfile.dat