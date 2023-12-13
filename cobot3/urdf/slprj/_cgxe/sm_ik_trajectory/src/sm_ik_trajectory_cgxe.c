/* Include files */

#include "sm_ik_trajectory_cgxe.h"
#include "m_Ip2BSC7RrazEPBoO6KQvJG.h"

unsigned int cgxe_sm_ik_trajectory_method_dispatcher(SimStruct* S, int_T method,
  void* data)
{
  if (ssGetChecksum0(S) == 2576042868 &&
      ssGetChecksum1(S) == 4177370574 &&
      ssGetChecksum2(S) == 3035953076 &&
      ssGetChecksum3(S) == 3417486402) {
    method_dispatcher_Ip2BSC7RrazEPBoO6KQvJG(S, method, data);
    return 1;
  }

  return 0;
}
