#pragma D option quiet

pid$target::malloc:entry,
pid$target::valloc:entry
{
  printf("probe: %s\n", probefunc);
  printf("TIME: %i\n", timestamp);
  printf("REQUESTED_BYTES: %i", arg0);
  ustack();
  printf("\n");
}

pid$target::calloc:entry,
pid$target::realloc:entry,
pid$target::reallocf:entry
 {
  printf("probe: %s\n", probefunc);
  printf("TIME: %i\n", timestamp);
  printf("REQUESTED_BYTES: %i", arg1);
  ustack();
  printf("\n");
}