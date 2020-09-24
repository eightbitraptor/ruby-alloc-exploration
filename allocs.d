#pragma D option quiet

pid$target::malloc:entry,
pid$target::valloc:entry
{
  printf("%s\n", probefunc);
  printf("%i\n", timestamp);
  printf("%i", arg0);
  ustack();
  printf("\n");
}

pid$target::calloc:entry,
pid$target::realloc:entry,
pid$target::reallocf:entry
 {
  printf("%s\n", probefunc);
  printf("%i\n", timestamp);
  printf("%i", arg1);
  ustack();
  printf("\n");
}